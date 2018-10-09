//
//  FilterTests.swift
//  KangarooStore_Tests
//
//  Created by Carlos Duclos on 8/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import KangarooStore

typealias Query = KangarooStore.Query

class FilterTests: XCTestCase {
    
    var kangaroo: KangarooStore!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: FilterTests.self)
        kangaroo = KangarooStore(name: "TestDB", storageType: .memory, bundle: bundle)
        kangaroo.loadStoreSync()
        kangaroo.save(in: .view, mode: .sync, block: { context in
            let entity2 = TestEntity(in: context)
            entity2.id = 2
            entity2.name = "entity2"
            entity2.lastname = "test"
            
            let entity1 = TestEntity(in: context)
            entity1.id = 1
            entity1.name = "entity1"
            entity1.lastname = "test"
            
            let entity5 = TestEntity(in: context)
            entity5.id = 5
            entity5.name = "entity5"
            entity5.lastname = "test"
            
            let entity6 = TestEntity(in: context)
            entity6.id = 6
            entity6.name = "entity6"
            entity6.lastname = "test"
        })
    }
    
    func testFilterInViewContext() {
        do {
            let predicate = NSPredicate(format: "id = %@", 1 as NSNumber)
            let query = Query<TestEntity>(in: kangaroo.viewContext).filtered(using: predicate)
            let entities = query.execute()
            
            XCTAssertEqual(entities.count, 1)
            XCTAssertEqual(entities[0].id, 1)
            XCTAssertEqual(entities[0].name, "entity1")
        }
    }
    
    func testFilterInBackgroundContext() {
        do {
            let predicate = NSPredicate(format: "lastname = %@", "test")
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).filtered(using: predicate)
            let entities = query.execute()
            XCTAssertEqual(entities.count, 4)
        }
    }
    
    func testNotEqualsThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where {
                \TestEntity.id != 5 && \TestEntity.lastname == "test"
            }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 3)
        }
    }
}

