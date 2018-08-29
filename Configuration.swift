//
//  Configuration.swift
//  KangarooStore
//
//  Created by Carlos Duclos on 8/28/18.
//

import Foundation

extension KangarooStore {
    
    /// Configuration for a core data store
    public enum Configuration {
        
        /// Default configuration 'Default'
        case `default`
        
        /// Custom configuration
        case custom(String)
    }
}

extension KangarooStore.Configuration {
    
    /// Returns the configuration name depending on the type
    internal var name: String? {
        
        switch self {
        case .default: return nil
        case .custom(let string): return string
        }
    }
}
