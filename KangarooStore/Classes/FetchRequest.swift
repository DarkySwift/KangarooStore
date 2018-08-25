//
//  FetchRequest.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/24/18.
//

import Foundation
import CoreData

public class FetchRequest<Entity: ManagedObject> {
    
    public fileprivate(set) var context: ManagedObjectContext
    public fileprivate(set) var offset: Int = 0
    public fileprivate(set) var limit: Int = 0
    public fileprivate(set) var batchSize: Int = 20
    public fileprivate(set) var predicate: NSPredicate? = nil
    public fileprivate(set) var sortDescriptors: [NSSortDescriptor]? = nil
    
    private var entity: NSEntityDescription {
        let name = String(describing: Entity.self)
        return NSEntityDescription.entity(forEntityName: name, in: context)!
    }
    
    public init (context: ManagedObjectContext) {
        self.context = context
    }
    
    public func toRaw<Result: NSFetchRequestResult>() -> NSFetchRequest<Result> {
        let rawValue = NSFetchRequest<Result>(entityName: entity.name!)
        rawValue.entity = entity
        rawValue.fetchOffset = offset
        rawValue.fetchLimit = limit
        rawValue.fetchBatchSize = (self.limit > 0 && self.batchSize > self.limit ? 0 : self.batchSize)
        rawValue.predicate = self.predicate
        rawValue.sortDescriptors = sortDescriptors
        return rawValue
    }
    
    public func sorted(by sortDescriptor: NSSortDescriptor) -> FetchRequest {
        guard var sortDescriptors = self.sortDescriptors else {
            self.sortDescriptors = [sortDescriptor]
            return self
        }
        sortDescriptors.append(sortDescriptor)
        return self
    }
    
    public func filtered(using predicate: NSPredicate) -> FetchRequest {
        guard let existingPredicate = self.predicate else {
            self.predicate = predicate
            return self
        }
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return self
    }
}
