import XCTest
import CoreData
@testable import KangarooStore

typealias Query = KangarooStore.Query

class Tests: XCTestCase {
    
    var kangaroo: KangarooStore!
    
    override func setUp() {
        super.setUp()
        
        let bundle = Bundle(for: Tests.self)
        kangaroo = KangarooStore(name: "TestDB", storageType: .memory, bundle: bundle)
        kangaroo.loadStoresSync()
        kangaroo.save(in: .view) { context in
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
        }
    }
    
    func testSortInViewContext() {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let query = Query<TestEntity>(context: kangaroo.viewContext).sorted(by: sortDescriptor)
        let entities = query.execute()
        
        XCTAssertEqual(entities.count, 4)
        XCTAssertEqual(entities[0].id, 1)
        XCTAssertEqual(entities[0].name, "entity1")
        XCTAssertEqual(entities[1].id, 2)
        XCTAssertEqual(entities[1].name, "entity2")
    }
    
    func testSortInBackgroundContext() {
        let sortDescriptor1 = NSSortDescriptor(key: "lastname", ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: "id", ascending: false)
        let query = Query<TestEntity>(context: kangaroo.backgroundContext).sorted(by: sortDescriptor2).sorted(by: sortDescriptor1)
        let entities = query.execute()
        
        entities.forEach { entity in
            print("entity", entity.id)
        }
        
        XCTAssertEqual(entities.count, 4)
        XCTAssertEqual(entities[0].id, 6)
        XCTAssertEqual(entities[0].name, "entity6")
        XCTAssertEqual(entities[0].lastname, "test")
        XCTAssertEqual(entities[3].id, 1)
        XCTAssertEqual(entities[3].name, "entity1")
        XCTAssertEqual(entities[3].lastname, "test")
    }
    
    func testFilterInViewContext() {
        do {
            let predicate = NSPredicate(format: "id = %@", 1 as NSNumber)
            let query = Query<TestEntity>(context: kangaroo.viewContext).filtered(using: predicate)
            let entities = query.execute()
            
            XCTAssertEqual(entities.count, 1)
            XCTAssertEqual(entities[0].id, 1)
            XCTAssertEqual(entities[0].name, "entity1")
        }
    }
    
    func testFilterInBackgroundContext() {
        do {
            let predicate = NSPredicate(format: "lastname = %@", "test")
            let query = Query<TestEntity>(context: kangaroo.backgroundContext).filtered(using: predicate)
            let entities = query.execute()
            
            XCTAssertEqual(entities.count, 4)
        }
    }
    
    func testNonOptionalsComparisons() {
        // less than
        do {
            let query = Query<TestEntity>(context: kangaroo.backgroundContext).filtered(using: predicate)
            let entities = query.execute()
        }
        
        // equals to
        do {
            let predicate: NSPredicate = (\TestEntity.name == "entity5")
            let query = Query<TestEntity>(context: kangaroo.backgroundContext).filtered(using: predicate)
            let entities = query.execute()
            
            XCTAssertEqual(entities.count, 1)
            XCTAssertEqual(entities[0].id, 5)
        }
        
        do {
            
        }
    }
}
