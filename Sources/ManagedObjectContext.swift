//
//  NSManagedObjectContext.swift
//  Kangaroo
//
//  Created by Carlos Duclos on 8/24/18.
//

import Foundation
import CoreData

public typealias ManagedObjectContext = NSManagedObjectContext

extension ManagedObjectContext {
    
    public func async<Value>(block: @escaping () throws -> Value, completion: ((Result<Value>) -> Void)? = nil) {
        perform {
            do {
                let value = try block()
                completion?(.success(value))
            } catch {
                completion?(.error(error))
            }
        }
    }
//    
//    public func async<Value>(block: @escaping () -> Value, completion: ((Value) -> Void)? = nil) {
//        perform {
//            let value = block()
//            completion?(value)
//        }
//    }
    
    @discardableResult
    public func sync<Value>(_ block: () throws -> Value) throws -> Value {
        var value: Value? = nil
        var outError: Error?
        
        performAndWait {
            do { try value = block() }
            catch { outError = error }
        }
        
        if let outError = outError {
            throw outError
        }
        
        return value!
    }
    
    @discardableResult
    public func sync<Value>(_ block: () -> Value) -> Value {
        var value: Value? = nil
        performAndWait {
            value = block()
        }
        return value!
    }
}

extension ManagedObjectContext {

    public enum Result<T> {
        
        case success(T)
        case error(Error)
    }
}
