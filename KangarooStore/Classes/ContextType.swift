//
//  ContextType.swift
//  KangarooStore
//
//  Created by Carlos Duclos on 8/28/18.
//

import Foundation

extension KangarooStore {
    
    public enum ContextType {        
        case view
        case background
        case custom(ManagedObjectContext)
    }
}
