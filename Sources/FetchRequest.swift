//
//  FetchRequest.swift
//  KangarooStore
//
//  Created by Carlos Duclos on 8/24/18.
//

import Foundation
import CoreData

/// Value type struct that represent a NSFetchRequest object
public struct FetchRequest<Entity: ManagedObject> {
    
    /// This setting allows you to specify an offset at which rows will begin being returned.
    /// Effectively, the request skips the specified number of matching entries.
    /// This property can be used to restrict the working set of data.
    /// In combination with fetchLimit, you can create a subrange of an arbitrary result set.
    public var offset: Int = 0
    
    /// The fetch limit specifies the maximum number of objects that a request should return when executed.
    public var limit: Int = 0
    
    /// The default value is 0. A batch size of 0 is treated as infinite, which disables the batch faulting behavior.
    /// If you set a nonzero batch size, the collection of objects returned when an instance of NSFetchRequest is executed is broken into batches
    public var batchSize: Int = 20
    
    /// The predicate instance constrains the selection of objects the NSFetchRequest instance is to fetch.
    public var predicate: NSPredicate? = nil
    
    /// The sort descriptors specify how the objects returned when the NSFetchRequest is issued should be ordered—for example, by last name and then by first name.
    public var sortDescriptors: [NSSortDescriptor]? = nil
    
    public var includePropertyValues: Bool = true
    
    private func entityDescription(in context: ManagedObjectContext) -> NSEntityDescription {
        let name = String(describing: Entity.self)
        return NSEntityDescription.entity(forEntityName: name, in: context)!
    }
    
    public init () { }
    
    public func toRaw<Result: NSFetchRequestResult>(in context: ManagedObjectContext) -> NSFetchRequest<Result> {
        let entity = entityDescription(in: context)
        let rawValue = NSFetchRequest<Result>(entityName: entity.name!)
        rawValue.entity = entity
        rawValue.fetchOffset = offset
        rawValue.fetchLimit = limit
        rawValue.fetchBatchSize = (self.limit > 0 && self.batchSize > self.limit ? 0 : self.batchSize)
        rawValue.predicate = predicate
        rawValue.sortDescriptors = sortDescriptors
        rawValue.includesPropertyValues = includePropertyValues
        return rawValue
    }
    
    internal func sorted(by sortDescriptors: [NSSortDescriptor]) -> FetchRequest {
        var copy = self
        if copy.sortDescriptors != nil {
            copy.sortDescriptors!.append(contentsOf: sortDescriptors)
        } else {
            copy.sortDescriptors = sortDescriptors
        }
        return copy
    }
    
    internal func filtered(using predicate: NSPredicate) -> FetchRequest {
        var copy = self
        if copy.predicate != nil {
            copy.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [copy.predicate!, predicate])
        } else {
            copy.predicate = predicate
        }
        return copy
    }
    
    internal func all() -> FetchRequest {
        var copy = self
        copy.predicate = nil
        return copy
    }
}
