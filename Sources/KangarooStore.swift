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
    public private(set) var viewContext: ManagedObjectContext
    
    public private(set) lazy var backgroundContext: ManagedObjectContext = {
        let context = ManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
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
        
        viewContext = ManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        viewContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        self.storageType = storageType
        self.databaseName = databaseName
        self.managedObjectModel = managedObjectModel
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextDidSave(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    /// Handler method that merges changes to other contexts
    @objc private func managedObjectContextDidSave(notification: Notification) {
        guard let changedContext = notification.object as? ManagedObjectContext else { return }
        
        let viewContext = self.viewContext
        let backgroundContext = self.backgroundContext
        
        if (changedContext === backgroundContext) {
            viewContext.mergeChanges(fromContextDidSave: notification)
            
        } else if (changedContext === viewContext) {
            backgroundContext.mergeChanges(fromContextDidSave: notification)
            
        } else {
            viewContext.mergeChanges(fromContextDidSave: notification)
            backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
        
        if shouldPatchCoreData {
            let privateQueueObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<ManagedObject> ?? []
            
            // Force the refresh of updated objects which may not have been registered in this context.
            let mainContextObjects = privateQueueObjects.map {
                (try? viewContext.existingObject(with: $0.objectID)) ?? viewContext.object(with: $0.objectID)
            }
            
            mainContextObjects.forEach {
                viewContext.refresh($0, mergeChanges: true)
                $0.willAccessValue(forKey: nil)
            }
        }
    }
    
    internal func getContext(from contextType: ContextType) -> ManagedObjectContext {
        switch contextType {
        case .view: return viewContext
        case .background: return backgroundContext
        case .custom(let context): return context
        }
    }
    
    /// Loads the store
    fileprivate func loadStore(configuration: Configuration = .default, completionHandler block: (() -> Void)? = nil) {
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                           NSInferMappingModelAutomaticallyOption : true ]
            let type = (storageType == .disk ? NSSQLiteStoreType : NSInMemoryStoreType)
            try persistentStoreCoordinator.addPersistentStore(ofType: type, configurationName: nil, at: storeURL, options: options)
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
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadStore(completionHandler: block)
        }
    }
}

extension KangarooStore {
    
    /// Saves the block changes in the previously initialized context type
    @discardableResult
    public func save(in contextType: ContextType, _ block: (ManagedObjectContext) -> Void) -> Error? {
        let context = getContext(from: contextType)
        block(context)
        do { try context.save(); return nil }
        catch { return error }
    }
}

extension KangarooStore {
 
    
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
