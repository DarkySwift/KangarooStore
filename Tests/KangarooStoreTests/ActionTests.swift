//
//  ActionTests.swift
//  KangarooStore_Example
//
//  Created by Carlos Duclos on 8/29/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import KangarooStore

class ActionTests: XCTestCase {
    
    var kangaroo: KangarooStore!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: SortTests.self)
        kangaroo = KangarooStore(name: "TestDB", storageType: .memory, bundle: bundle)
        kangaroo.loadStoreSync()
        kangaroo.saveSync(in: .view, block: { context in
            let entity1 = TestEntity(in: context)
            entity1.id = 1
            entity1.name = "entity1"
            entity1.lastname = "test"
            
            let entity2 = TestEntity(in: context)
            entity2.id = 2
            entity2.name = "entity2"
            entity2.lastname = "test"
        })
    }
    
    func testMergeChangesBetweenContexts() {
        do {
            kangaroo.saveSync(in: .view, block: { context in
                let entity3 = TestEntity(in: context)
                entity3.id = 3
                entity3.name = "entity3"
                entity3.lastname = "test"
            })
            
            let entities = Query<TestEntity>(in: kangaroo.newTemporaryContext)
            XCTAssertEqual(entities.count, 3)
        }
        
        do {
            let context = kangaroo.newTemporaryContext
            kangaroo.saveSync(in: .temporary(context), block: { context in
                let entity4 = TestEntity(in: context)
                entity4.id = 4
                entity4.name = "entity4"
                entity4.lastname = "test"
            })
            
            let entities = Query<TestEntity>(in: kangaroo.viewContext)
            XCTAssertEqual(entities.count, 4)
        }
    }
}
