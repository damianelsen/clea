//
//  CleaTests.swift
//  CleaTests
//
//  Created by Damian Elsen on 7/19/18.
//  Copyright © 2018 Damian Elsen. All rights reserved.
//

import XCTest
@testable import Clea

class CleaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - RoomModel Class Tests
    
    func testRoomModelInitializationSucceeds() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomType = RoomType(context: managedObjectContext)

        // Valid Room
        let validRoom = RoomModel.init(name: "roomName", type: roomType)
        XCTAssertNotNil(validRoom)
        
        managedObjectContext.rollback()
    }
    
    func testRoomModelInitializationFails() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let roomType = RoomType(context: managedObjectContext)
        
        // Empty Room name
        let emptyRoomName = RoomModel.init(name: "", type: roomType)
        XCTAssertNil(emptyRoomName)
    }
}
