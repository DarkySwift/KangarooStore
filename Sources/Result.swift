//
//  Result.swift
//  KangarooStore-iOS
//
//  Created by Carlos Duclos on 10/8/18.
//  Copyright © 2018 KangarooStore. All rights reserved.
//

import Foundation

public extension KangarooStore {
    
    enum Result<T> {
        case success(T)
        case error(Error)
    }
}

extension KangarooStore.Result where T == Void {
    
    static var success: KangarooStore.Result<()> {
        return .success(())
    }
}
