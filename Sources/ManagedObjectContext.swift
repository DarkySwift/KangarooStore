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
    
//    public func async(block: @escaping () -> Void) {
//        perform {
//            block()
//        }
//    }
    
    public enum Mode {
        case sync
        case async
    }
    
    public func perform(_ mode: Mode, block: @escaping () -> Void) {
        switch mode {
        case .sync:
            self.performAndWait {
                block()
            }
        case .async:
            self.perform {
                block()
            }
        }
    }
    
    public func async<Value>(block: @escaping () -> Value, completion: ((Value) -> Void)? = nil) {
        perform {
            completion?(block())
        }
    }

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
//
//    @discardableResult
//    public func sync<Value>(_ block: () -> Value) -> Value {
//        var value: Value? = nil
//        performAndWait {
//            value = block()
//        }
//        return value!
//    }
}
