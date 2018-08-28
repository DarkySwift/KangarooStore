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
    
    @objc private func managedObjectContextDidSave(notification: Notification) {
        guard let changedContext = notification.object as? ManagedObjectContext else { return }
        
        let viewContext = self.viewContext
        let backgroundContext = self.backgroundContext
        
        if (changedContext === self.backgroundContext) {
            viewContext.mergeChanges(fromContextDidSave: notification)
            
        } else if (changedContext === self.viewContext) {
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
    
    // MARK: - Methods
    
    fileprivate func loadStores(completionHandler block: (() -> Void)? = nil) {
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                           NSInferMappingModelAutomaticallyOption : true ]
            
            let type = (storageType == .disk ? NSSQLiteStoreType : NSInMemoryStoreType)
            try persistentStoreCoordinator.addPersistentStore(ofType: type, configurationName: nil, at: storeURL, options: options)
        } catch {
            fatalError("Error adding store: \(error)")
        }
    }
    
    public func loadStoresSync() {
        self.loadStores()
    }
    
    public func loadStoresAsync(completionHandler block: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadStores(completionHandler: block)
        }
    }
    
    @discardableResult
    public func save(in contextType: ContextType, _ block: (ManagedObjectContext) -> Void) -> Error? {
        var context: ManagedObjectContext {
            switch contextType {
            case .view: return viewContext
            case .background: return backgroundContext
            case .custom(let context): return context
            }
        }
        
        block(context)
        do { try context.save(); return nil }
        catch { return error }
    }
    
//    public func query<Entity: ManagedObject>(in context: ManagedObjectContext) -> Query {
//        let query = Query<Entity>(context: context)
//        return query.execute()
//    }
}
