//
//  Persistency.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/23/18.
//

import Foundation
import CoreData

public class KangarooStore {
    
    // MARK: - Properties
    
    public static var defaultComparisonOptions: NSComparisonPredicate.Options = [.caseInsensitive, .diacriticInsensitive]
    
    private lazy var shouldPatchCoreData: Bool =
        ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10,
                                                                      minorVersion: 0,
                                                                      patchVersion: 0)) == false
    
    public private(set) var storageType: StorageType
    public private(set) var databaseName: String
    public private(set) var directoryURL: URL!
    public private(set) var managedObjectModel: NSManagedObjectModel
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator
    //    public private(set) var viewContext: ManagedObjectContext
    
    public private(set) lazy var masterContext: ManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
    public lazy var viewContext: ManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = masterContext
        return context
    }()
    
    public var newTemporaryContext: ManagedObjectContext {
        let context = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext
        return context
    }
    
    public var storeURL: URL {
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docURL.appendingPathComponent("\(self.databaseName).sqlite")
    }
    
    // MARK: - Initialize
    
    public init(name databaseName: String, storageType: StorageType = .disk, bundle: Bundle? = nil, directoryURL url: URL? = nil) {
        let theBundle = bundle ?? Bundle.main
        
        guard let modelURL = theBundle.url(forResource: databaseName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        //        viewContext = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        //        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        self.storageType = storageType
        self.databaseName = databaseName
        self.managedObjectModel = managedObjectModel
        
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(managedObjectContextDidSave(notification:)),
        //                                               name: .NSManagedObjectContextDidSave,
        //                                               object: nil)
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
            guard let `self` = self else { return }
            
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
            guard let `self` = self else { return }
            
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
            guard let `self` = self else { return }
            
            do {
                try self.masterContext.save()
                completion?(.success)
            } catch {
                completion?(.error(error))
                assertionFailure("CORE DATA MASTER CONTEXT ERROR: \(error)")
            }
        }
    }
    
    func clearAll<Entity: ManagedObject>(for entity: Entity.Type, in context: ManagedObjectContext? = nil) {
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
