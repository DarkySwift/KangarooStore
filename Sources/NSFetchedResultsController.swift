//
//  NSFetchedResultsController.swift
//  CoreVendors
//
//  Created by Carlos Duclos on 9/15/18.
//  Copyright © 2018 Land Gorilla. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectModel {
    
    subscript(managedObjectType: NSManagedObject.Type) -> NSEntityDescription? {
        
        // search for entity with class name
        
        let className = NSStringFromClass(managedObjectType)
        
        return self.entities.first { $0.managedObjectClassName == className }
    }
}

public func NSFetchedResultsController <T: NSManagedObject>
    (_ managedObjectType: T.Type,
     delegate: NSFetchedResultsControllerDelegate? = nil,
     predicate: NSPredicate? = nil,
     sortDescriptors: [NSSortDescriptor] = [],
     sectionNameKeyPath: String? = nil,
     context: NSManagedObjectContext) -> NSFetchedResultsController<NSManagedObject> {
    
    let entity = context.persistentStoreCoordinator!.managedObjectModel[managedObjectType]!
    
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity.name!)
    
    fetchRequest.predicate = predicate
    
    fetchRequest.sortDescriptors = sortDescriptors
    
    let fetchedResultsController = CoreData.NSFetchedResultsController.init(fetchRequest: fetchRequest,
                                                                            managedObjectContext: context,
                                                                            sectionNameKeyPath: sectionNameKeyPath,
                                                                            cacheName: nil)
    
    fetchedResultsController.delegate = delegate
    
    return fetchedResultsController
}
