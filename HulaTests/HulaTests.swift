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

    func testCategoriesFromJSONBuildsNewArray() {
        let json: [Any] = [
            ["name": "CLOTHING", "icon": "icon_cat_clothing", "num_products": 3],
            ["name": "SPORTS", "icon": "icon_cat_sport", "num_products": 1]
        ]
        let categories = HLDataManager.categories(from: json)
        XCTAssertEqual(categories.count, 2)
        let first = categories.object(at: 0) as? [String: Any]
        XCTAssertEqual(first?["name"] as? String, "CLOTHING")
    }

    func testCategoriesFromNilOrMalformedIsEmpty() {
        XCTAssertEqual(HLDataManager.categories(from: nil).count, 0)
        XCTAssertEqual(HLDataManager.categories(from: ["not": "an array"]).count, 0)
    }

    func testClearSessionCachesDropsTradesAndNotifications() {
        let dm = HLDataManager.sharedInstance
        dm.arrTrades = [["_id": "t1"] as NSDictionary]
        dm.arrCurrentTrades = [["_id": "t1", "owner_id": "u1", "other_id": "u2"] as NSDictionary]
        dm.arrPastTrades = [["_id": "t0"] as NSDictionary]
        dm.arrNotifications = [["_id": "n1"] as NSDictionary]
        dm.numNotificationsPending = 4
        dm.isLoadingNotifications = true
        dm.isInSwapVC = true

        dm.clearSessionCaches()

        XCTAssertEqual(dm.arrTrades.count, 0)
        XCTAssertEqual(dm.arrCurrentTrades.count, 0)
        XCTAssertEqual(dm.arrPastTrades.count, 0)
        XCTAssertEqual(dm.arrNotifications.count, 0)
        XCTAssertEqual(dm.numNotificationsPending, 0)
        XCTAssertFalse(dm.isLoadingNotifications)
        XCTAssertFalse(dm.isInSwapVC)
        XCTAssertFalse(dm.amITradingWith("u1"))
        XCTAssertFalse(dm.myRoomsFull())
    }

    func testTradeRoomCountNilSafe() {
        XCTAssertEqual(HLDashboardViewController.tradeRoomCount(tradeCount: nil, maxTrades: 3), 3)
        XCTAssertEqual(HLDashboardViewController.tradeRoomCount(tradeCount: 0, maxTrades: 3), 3)
        XCTAssertEqual(HLDashboardViewController.tradeRoomCount(tradeCount: 5, maxTrades: 3), 5)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
