//
//  Persistency.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/23/18.
//

import Foundation
import CoreData

open class KangarooStore {
    
    // MARK: - Properties
    
    public static var defaultComparisonOptions: NSComparisonPredicate.Options = [.caseInsensitive, .diacriticInsensitive]
    
    public private(set) var storageType: StorageType
    public private(set) var databaseName: String
    public private(set) var directoryURL: URL!
    public private(set) var managedObjectModel: NSManagedObjectModel
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    public private(set) lazy var masterContext: ManagedObjectContext = { [weak self] in
        let context = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self?.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    public lazy var viewContext: ManagedObjectContext = { [weak self] in
        let context = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.parent = self?.masterContext
        return context
    }()
    
    public var newTemporaryContext: ManagedObjectContext {
        let context = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.parent = viewContext
        return context
    }
    
    public var storeURL: URL
    
    // MARK: - Initialize
    
    public init(name databaseName: String,
                storageType: StorageType = .disk,
                bundle: Bundle? = nil,
                storeURL url: URL? = nil) {
        let theBundle = bundle ?? Bundle.main
        let storeURL = url ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        guard let modelURL = theBundle.url(forResource: databaseName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        self.storageType = storageType
        self.storeURL = storeURL.appendingPathComponent("\(databaseName).sqlite")
        self.databaseName = databaseName
        self.managedObjectModel = managedObjectModel
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    
    internal func getContext(from contextType: ContextType) -> ManagedObjectContext {
        switch contextType {
        case .view: return viewContext
        case .temporary(let context): return context
        }
    }
    
    /// Loads the store
    fileprivate func loadStore(configuration: Configuration = .default, completionHandler block: (() -> Void)? = nil) {
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                           NSInferMappingModelAutomaticallyOption : true ]
            let type = (storageType == .disk ? NSSQLiteStoreType : NSInMemoryStoreType)
            try persistentStoreCoordinator.addPersistentStore(ofType: type, configurationName: nil, at: storeURL, options: options)
            block?()
        } catch {
            fatalError("Error adding store: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    public func hasPersistentStore(type: String) -> Bool {
        return persistentStoreCoordinator.persistentStores.filter { $0.type == type }.count > 0
    }
    
    /// Loads the store synchronously
    public func loadStoreSync() {
        loadStore()
    }
    
    /// Loads the store asynchronously
    public func loadStoreAsync(completionHandler block: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.loadStore(completionHandler: block)
        }
    }
    
    public func save(in type: ContextType, block: @escaping (ManagedObjectContext) throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            saveAsync(in: type, block: block) { result in
                switch result {
                case .success:
                    continuation.resume(with: .success(()))
                case .error(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    public func saveAsync(in type: ContextType,
                          block: @escaping (ManagedObjectContext) throws -> Void,
                          completion: ((Result<()>) -> Void)? = nil) {
        
        switch type {
        case .view:
            saveViewContext(mode: .async, block: block, completion: completion)
            
        case .temporary(let context):
            saveTemporary(context: context, mode: .async, block: block, completion: completion)
        }
    }
    
    public func saveSync(in type: ContextType,
                         block: @escaping (ManagedObjectContext) throws -> Void) {
        
        switch type {
        case .view:
            saveViewContext(mode: .sync, block: block)
            
        case .temporary(let context):
            saveTemporary(context: context, mode: .sync, block: block)
        }
    }
    
    public func saveTemporary(context: ManagedObjectContext,
                              mode: ManagedObjectContext.Mode,
                              block: @escaping (ManagedObjectContext) throws -> Void,
                              completion: ((Result<()>) -> Void)? = nil) {
        context.perform(mode) { [weak self] in
            guard let self = self else { return }
            
            do {
                try block(context)
                try context.save()
                self.saveViewContext(mode: mode, completion: completion)
            } catch {
                completion?(.error(error))
                assertionFailure("CORE DATA TEMPORARY CONTEXT ERROR: \(error)")
            }
        }
    }
    
    public func saveViewContext(mode: ManagedObjectContext.Mode,
                                block: ((ManagedObjectContext) throws -> Void)? = nil,
                                completion: ((Result<()>) -> Void)? = nil) {
        
        viewContext.perform(mode) { [weak self] in
            guard let self = self else { return }
            
            do {
                try block?(self.viewContext)
                try self.viewContext.save()
                self.saveMasterContext(mode: mode, completion: completion)
            } catch {
                completion?(.error(error))
                assertionFailure("CORE DATA VIEW CONTEXT ERROR: \(error)")
            }
        }
    }
    
    internal func saveMasterContext(mode: ManagedObjectContext.Mode,
                                    completion: ((Result<()>) -> Void)? = nil) {
        
        masterContext.perform(mode) { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.masterContext.save()
                completion?(.success)
            } catch {
                completion?(.error(error))
                assertionFailure("CORE DATA MASTER CONTEXT ERROR: \(error)")
            }
        }
    }
    
    public func clearAll<Entity: ManagedObject>(for entity: Entity.Type, in context: ManagedObjectContext? = nil) {
        let usedContext = context ?? viewContext
        let entities = Query<Entity>(in: usedContext).all(includeProperties: false)
        entities.forEach { usedContext.delete($0) }
    }
}

extension KangarooStore {
    
    public func fetchRequest<Entity: NSFetchRequestResult>(with name: String) -> NSFetchRequest<Entity> {
        return managedObjectModel.fetchRequestTemplate(forName: name) as! NSFetchRequest<Entity>
    }
    
    public func fetchRequest<Entity: NSFetchRequestResult>(with name: String,
                                                           substitutionVariables: [String : Any]) -> NSFetchRequest<Entity> {
        return managedObjectModel.fetchRequestFromTemplate(withName: name,
                                                           substitutionVariables: substitutionVariables) as! NSFetchRequest<Entity>
    }
}
