//
//  NSManagedObject.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/24/18.
//

import Foundation
import CoreData

public typealias ManagedObject = NSManagedObject

extension ManagedObject {
    
    public convenience init(in context: ManagedObjectContext) {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { fatalError("Wrong entity name") }
        self.init(entity: entity, insertInto: context)
    }
    
    internal static func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { fatalError("Wrong entity name") }
        return entity
    }
    
    public func entityDescription(in context: NSManagedObjectContext) -> NSEntityDescription {
        let name = String(describing: type(of: self))
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { fatalError("Wrong entity name") }
        return entity
    }
    
    public final func inContext(_ otherContext: ManagedObjectContext) throws -> Self {
        guard otherContext !== managedObjectContext else { return self }
        
        if objectID.isTemporaryID {
            try otherContext.obtainPermanentIDs(for: [self])
        }
        
        let otherManagedObject = try otherContext.existingObject(with: objectID)
        return unsafeDowncast(otherManagedObject, to: type(of: self))
    }
}

extension ManagedObject {
    
    public final func delete() {
        guard let managedObjectContext = self.managedObjectContext else { fatalError("Context does not exist") }
        managedObjectContext.delete(self)
    }
    
    public final func refresh(mergeChanges: Bool = true) {
        guard let managedObjectContext = self.managedObjectContext else { fatalError("Context does not exist") }
        managedObjectContext.refresh(self, mergeChanges: mergeChanges)
    }
}

extension ManagedObject {
    
    public subscript(key: String) -> Any? {
        return self.value(forKey: key)
    }
}
