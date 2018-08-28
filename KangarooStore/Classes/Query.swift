//
//  Query.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/24/18.
//

import Foundation
import CoreData

extension KangarooStore {
    
    public class Query<Entity: ManagedObject> {
        
        public let context: ManagedObjectContext
        public var fetchRequest: FetchRequest<Entity>
        
        public init(context: ManagedObjectContext, fetchRequest: FetchRequest<Entity>? = nil) {
            self.context = context
            self.fetchRequest = fetchRequest ?? FetchRequest<Entity>(context: context)
        }
        
        public func execute() -> [Entity] {
            return try! context.fetch(fetchRequest.toRaw())
        }
        
        public var count: Int {
            return try! context.count(for: fetchRequest.toRaw())
        }
        
        public func first() -> Entity? {
            return execute().first
        }
        
        public func last() -> Entity? {
            return execute().last
        }
        
        public func filtered(using predicate: NSPredicate) -> Query {
            fetchRequest = fetchRequest.filtered(using: predicate)
            return self
        }
        
        public func filtered(_ block: () -> NSPredicate) -> Query {
            fetchRequest = fetchRequest.filtered(using: block())
            return self
        }
        
        public func sorted(by sortDescriptor: NSSortDescriptor) -> Query {
            fetchRequest = fetchRequest.sorted(by: sortDescriptor)
            return self
        }
    }

}

