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
            
            let entities = try? copy.executeSync()
            return entities?.first
        }

        /// Executes the query and returns the last entity that matches
        public func last() -> Entity? {
            var copy = self
            copy.fetchRequest.limit = 1
            
            let entities = try? copy.executeSync()
            return entities?.last
        }
        
        public func filtered(using predicate: NSPredicate) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.filtered(using: predicate)
            return copy
        }
        
        public func `where`(_ block: () -> NSPredicate) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.filtered(using: block())
            return copy
        }
        
        public func all(includeProperties: Bool = true) -> [Entity] {
            var copy = self
            copy.fetchRequest.includePropertyValues = includeProperties
            copy.fetchRequest = fetchRequest.all()
            return copy.execute()
        }
        
        public func order(by sortDescriptor: NSSortDescriptor) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.sorted(by: [sortDescriptor])
            return copy
        }
        
        public func order(by sortDescriptors: NSSortDescriptor...) -> Query {
            var copy = self
            copy.fetchRequest = fetchRequest.sorted(by: sortDescriptors)
            return copy
        }
        
        public func execute() -> [Entity] {
            let entities = try? executeSync()
            return entities ?? []
        }
        
        public func executeSync() throws -> [Entity] {
            let context = self.context
            let fetchRequest = self.fetchRequest
            
            return try context.sync {
                try context.fetch(fetchRequest.toRaw(in: context))
            }
        }

        public func executeAsync(completion: ((Result<[Entity]>) -> Void)? = nil) {
            let context = self.context
            let fetchRequest = self.fetchRequest
            
            context.perform {
                do {
                    let entities: [Entity] = try context.fetch(fetchRequest.toRaw(in: context)) as [Entity]
                    completion?(.success(entities))
                } catch {
                    completion?(.error(error))
                }
            }
        }
    }
}

extension KangarooStore.Query {
    
    public func create() -> Entity {
        let name = String(describing: Entity.self)
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { fatalError("Wrong entity name") }
        return ManagedObject(entity: entity, insertInto: context) as! Entity
    }
    
    
    
    public func findOrCreateFirst() -> Entity {
        guard let existingEntity = first() else { return create() }
        return existingEntity
    }
    
    public func findByAttribute<Value: Equatable>(keypath: ReferenceWritableKeyPath<Entity, Value>,
                                                   value: Value) -> Entity? {
        return self.where({ keypath == value }).first()
    }
    
    public func findOrCreate(where block: () -> NSPredicate) -> Entity {
        return findOrCreate(where: block())
    }

    public func findOrCreate(where predicate: NSPredicate) -> Entity {
        guard let existingEntity = filtered(using: predicate).first() else { return create() }
        return existingEntity
    }
}

extension KangarooStore.Query {
    
    public func delete(where block: () -> NSPredicate) {
        let request = fetchRequest.toRaw(in: context) as NSFetchRequest<NSManagedObjectID>
        request.resultType = .managedObjectIDResultType
        request.predicate = block()
        
        do {
            let ids = try context.fetch(request)
            try ids.forEach {
                let object = try context.existingObject(with: $0)
                self.context.delete(object)
            }
        } catch let error {
            print(error)
        }
    }
    
    public func delete(_ entity: Entity) {
        context.delete(entity)
    }
    
    public func deleteAll() throws {
        let request = fetchRequest.toRaw(in: context) as NSFetchRequest<NSManagedObjectID>
        request.resultType = .managedObjectIDResultType
        
        let ids = try context.fetch(request)
        for id in ids {
            let object = try context.existingObject(with: id)
            self.context.delete(object)
        }
    }
}
