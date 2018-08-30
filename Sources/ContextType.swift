//
//  ContextType.swift
//  KangarooStore
//
//  Created by Carlos Duclos on 8/28/18.
//

import Foundation

extension KangarooStore {
    
    public enum ContextType {
        
        /// Represents the main context
        case view
        
        /// Represents the private queue context
        case background
        
        /// Represents a custom context
        case custom(ManagedObjectContext)
    }
}
