//
//  Query.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/24/18.
//

import Foundation
import CoreData

extension KangarooStore {
    
    public struct Query<Entity: ManagedObject> {
        
        public let context: ManagedObjectContext
        public var fetchRequest: FetchRequest<Entity>
        
        public init(in context: ManagedObjectContext, fetchRequest: FetchRequest<Entity> = FetchRequest<Entity>()) {
            self.context = context
            self.fetchRequest = fetchRequest
        }
        
        /// Executes the query and returns the number of entities
        public var count: Int {
            return try! context.count(for: fetchRequest.toRaw(in: context))
        }
        
        /// Executes the query and returns the first entity that matches
        public func first() -> Entity? {
            var copy = self
            copy.fetchRequest.limit = 1
            return copy.execute().first
        }
        
        /// Executes the query and returns the last entity that matches
        public func last() -> Entity? {
            var copy = self
            copy.fetchRequest.limit = 1
            return copy.execute().last
        }
        
        public func filtered(using predicate: NSPredicate) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.filtered(using: predicate)
            return copy
        }
        
        public func filtered(_ block: () -> NSPredicate) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.filtered(using: block())
            return copy
        }
        
        public func sorted(by sortDescriptor: NSSortDescriptor) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.sorted(by: sortDescriptor)
            return copy
        }
        
        public func execute() -> [Entity] {
            return try! context.fetch(fetchRequest.toRaw(in: context))
        }
    }
}

