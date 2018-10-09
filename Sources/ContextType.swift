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
        
        /// Represents a custom context
        case temporary(ManagedObjectContext)
    }
}
