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
    
    func testTradeLoadFromEmptyBidsDoesNotCrash() {
        let trade = HulaTrade()
        trade.num_bids = 3
        trade.last_bid_diff = ["stale-product"]

        trade.loadFrom(dict: [
            "_id": "trade-1",
            "bids": []
        ] as NSDictionary)

        XCTAssertEqual(trade.tradeId, "trade-1")
        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertEqual(trade.last_bid_diff, [])
    }

    func testTradeLoadFromAbsentBidsResetsBidState() {
        let trade = HulaTrade()
        trade.num_bids = 2
        trade.last_bid_diff = ["stale-product"]

        trade.loadFrom(dict: [
            "_id": "trade-2"
        ] as NSDictionary)

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertEqual(trade.last_bid_diff, [])
    }

    func testTradeLoadFromUsesLatestBidDiffs() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "bids": [
                ["owner_diff": ["old-a"], "other_diff": ["old-b"]],
                ["owner_diff": ["new-a"], "other_diff": ["new-b"]]
            ]
        ] as NSDictionary)

        XCTAssertEqual(trade.num_bids, 2)
        XCTAssertEqual(trade.last_bid_diff, ["new-a", "new-b"])
    }

    func testTradeLoadFromIgnoresUnparsableDates() {
        let trade = HulaTrade()
        let originalDate = trade.date
        let originalLastUpdate = trade.last_update

        trade.loadFrom(dict: [
            "date": "not-a-date",
            "last_update": "2026-07-24T15:00:00Z"
        ] as NSDictionary)

        XCTAssertEqual(trade.date.timeIntervalSince1970, originalDate.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(trade.last_update.timeIntervalSince1970, originalLastUpdate.timeIntervalSince1970, accuracy: 0.001)
    }

    func testTradeLoadFromAcceptsFractionalISO8601Dates() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "date": "2026-07-24T15:00:00.000Z",
            "last_update": "2026-07-24T16:30:00.123Z"
        ] as NSDictionary)

        XCTAssertEqual(trade.date.iso8601, "2026-07-24T15:00:00.000Z")
        XCTAssertEqual(trade.last_update.iso8601, "2026-07-24T16:30:00.123Z")
    }

    func testProductPostStringEncodesFormDelimiters() {
        let product = HulaProduct()
        product.productName = "Salt & Pepper"
        product.productDescription = "a=b"
        product.productCondition = "good"
        product.productCategory = "Kitchen"
        product.productCategoryId = "cat-1"
        product.productImage = "https://example.com/img.jpg"
        product.productOwner = "owner-1"
        product.arrProductPhotoLink = ["https://example.com/a.jpg"]

        let body = product.getPostString()
        XCTAssertTrue(body.contains("title=Salt%20%26%20Pepper"))
        XCTAssertTrue(body.contains("description=a%3Db"))
        XCTAssertFalse(body.contains("title=Salt & Pepper"))
        XCTAssertFalse(body.contains("&description=a=b&"))
    }

    func testUserPostStringEncodesFormDelimiters() {
        let user = HulaUser()
        user.userEmail = "a@b.com"
        user.userName = "Ann & Bob"
        user.userBio = "likes A&B"
        user.userNick = "ann"
        user.userPhotoURL = "https://example.com/u.jpg?x=1&y=2"
        user.twToken = ""
        user.liToken = ""
        user.fbToken = ""
        user.deviceId = "device-1"
        user.zip = "10001"
        user.maxTrades = 3

        let body = user.getPostString()
        XCTAssertTrue(body.contains("name=Ann%20%26%20Bob"))
        XCTAssertTrue(body.contains("bio=likes%20A%26B"))
        XCTAssertTrue(body.contains("image=https://example.com/u.jpg?x%3D1%26y%3D2"))
        XCTAssertFalse(body.contains("name=Ann & Bob"))
        XCTAssertFalse(body.contains("&bio=likes A&B&"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
