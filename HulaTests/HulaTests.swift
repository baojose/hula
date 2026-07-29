//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
@testable import Hula

class HulaTests: XCTestCase {
    
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
    
    /// Regression: Accept/Reject used object(at:) with a stale cell tag after refresh
    /// cleared or shrunk arrNotifications, which threw NSRangeException.
    func testNotificationAtIndexIsBoundsSafe() {
        let manager = HLDataManager.sharedInstance
        let previous = manager.arrNotifications
        defer { manager.arrNotifications = previous }

        manager.arrNotifications = NSMutableArray()
        XCTAssertNil(manager.notification(at: 0))
        XCTAssertNil(manager.notification(at: -1))

        manager.arrNotifications.add(["_id": "n1", "type": "start"] as NSDictionary)
        XCTAssertNotNil(manager.notification(at: 0))
        XCTAssertNil(manager.notification(at: 1))
        XCTAssertEqual(manager.notification(at: 0)?["_id"] as? String, "n1")
    }

}
