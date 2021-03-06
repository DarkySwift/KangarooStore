//
//  ComparisonTests.swift
//  KangarooStore_Tests
//
//  Created by Carlos Duclos on 8/28/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
@testable import KangarooStore

class ComparisonTests: XCTestCase {
    
    var kangaroo: KangarooStore!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: ComparisonTests.self)
        kangaroo = KangarooStore(name: "TestDB", storageType: .memory, bundle: bundle)
        kangaroo.loadStoreSync()
        kangaroo.saveSync(in: .view, block: { context in
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
    
    func testLessThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id < 4 }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 2)
        }
        
        do {
            let optional: Int32? = 4
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id < optional }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 2)
        }
    }
    
    func testLessOrEqualsThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id <= 5 }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 3)
        }
        
        do {
            let optional: Int32? = 5
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id <= optional }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 3)
        }
    }
    
    func testGreaterThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id > 4 }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 2)
        }
        
        do {
            let optional: Int32? = 4
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id > optional }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 2)
        }
    }
    
    func testGreaterOrEqualsThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id >= 5 }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 2)
        }
        
        do {
            let optional: Int32? = 5
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id >= optional }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 2)
        }
    }
    
    func testEqualsThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id == 5 }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 1)
        }
        
        do {
            let optional: Int32? = 5
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id == optional }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 1)
        }
    }
    
    func testNotEqualsThanComparison() {
        do {
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id != 5 }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 3)
        }
        
        do {
            let optional: Int32? = 5
            let query = Query<TestEntity>(in: kangaroo.newTemporaryContext).where { \TestEntity.id != optional }
            let entities = query.execute()
            XCTAssertEqual(entities.count, 3)
        }
    }
    
}
