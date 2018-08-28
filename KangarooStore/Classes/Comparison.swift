//
//  Comparison.swift
//  KangarooStore
//
//  Created by Carlos Duclos on 8/28/18.
//

import Foundation

public func < <Entity: ManagedObject, Value: Comparable>(lhs: KeyPath<Entity, Value>, rhs: Value) -> NSPredicate {
    return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
                                 rightExpression: NSExpression(forConstantValue: rhs),
                                 modifier: .direct,
                                 type: .lessThan,
                                 options: rhs.comparisonOptions)
}

public func <= <Entity: ManagedObject, Value: Comparable>(lhs: KeyPath<Entity, Value>, rhs: Value) -> NSPredicate {
    return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
                                 rightExpression: NSExpression(forConstantValue: rhs),
                                 modifier: .direct,
                                 type: .lessThanOrEqualTo,
                                 options: rhs.comparisonOptions)
}

public func > <Entity: ManagedObject, Value: Comparable>(lhs: KeyPath<Entity, Value>, rhs: Value) -> NSPredicate {
    return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
                                 rightExpression: NSExpression(forConstantValue: rhs),
                                 modifier: .direct,
                                 type: .greaterThan,
                                 options: rhs.comparisonOptions)
}

public func >= <Entity: ManagedObject, Value: Comparable>(lhs: KeyPath<Entity, Value>, rhs: Value) -> NSPredicate {
    return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
                                 rightExpression: NSExpression(forConstantValue: rhs),
                                 modifier: .direct,
                                 type: .greaterThanOrEqualTo,
                                 options: rhs.comparisonOptions)
}
    
public func == <Entity: ManagedObject, Value: Equatable>(lhs: KeyPath<Entity, Value>, rhs: Value) -> NSPredicate {
    return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
                                 rightExpression: NSExpression(forConstantValue: rhs),
                                 modifier: .direct,
                                 type: .equalTo,
                                 options: rhs.comparisonOptions)
}

public func != <Entity: ManagedObject, Value: Equatable>(lhs: KeyPath<Entity, Value>, rhs: Value) -> NSPredicate {
    return NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: lhs),
                                 rightExpression: NSExpression(forConstantValue: rhs),
                                 modifier: .direct,
                                 type: .notEqualTo,
                                 options: rhs.comparisonOptions)
}

extension Equatable {
    
    var comparisonOptions: NSComparisonPredicate.Options {
        guard self is String || self is NSString else { return [] }
        return KangarooStore.defaultComparisonOptions
    }
}
