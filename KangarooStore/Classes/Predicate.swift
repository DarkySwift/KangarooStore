//
//  Predicate.swift
//  KangarooStore
//
//  Created by Carlos Duclos on 8/28/18.
//

import Foundation
import CoreData

public class Predicate: RawRepresentable {
    
    public let rawValue: NSPredicate
    
    public var predicateFormat: String { return self.rawValue.predicateFormat }
    
    public required init(rawValue: NSPredicate) {
        self.rawValue = rawValue
    }
    
    public convenience init(format: String, argumentArray arguments: [Any]?) {
        self.init(rawValue: NSPredicate(format: format, argumentArray: arguments))
    }
    
    public convenience init(format: String, arguments: CVaListPointer) {
        self.init(format: format, arguments: arguments)
    }
    
    public convenience init(value: Bool) {
        self.init(rawValue: NSPredicate(value: value))
    }
}
