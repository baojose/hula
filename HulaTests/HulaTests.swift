//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Hula

class HulaTests: XCTestCase {

    override func setUp() {
        super.setUp()
        resetSharedUser()
    }

    override func tearDown() {
        resetSharedUser()
        super.tearDown()
    }

    func testFeedbackUsesDashWhenNoFeedbackAndRoundedPercentageWhenPresent() {
        let user = HulaUser.sharedInstance
        user.feedback_count = 0.0
        user.feedback_points = 0.0
        XCTAssertEqual(user.getFeedback(), "-")

        user.feedback_count = 3.0
        user.feedback_points = 2.0
        XCTAssertEqual(user.getFeedback(), "67%")
    }

    func testUserLoggedInRequiresBothUserIdAndToken() {
        let user = HulaUser.sharedInstance

        user.userId = "user-123"
        user.token = ""
        XCTAssertFalse(user.isUserLoggedIn())

        user.userId = ""
        user.token = "token-abc"
        XCTAssertFalse(user.isUserLoggedIn())

        user.userId = "user-123"
        user.token = "token-abc"
        XCTAssertTrue(user.isUserLoggedIn())
    }

    func testIncompleteProfileRequiresPublicProfileFields() {
        fillCompleteProfile()
        XCTAssertFalse(HulaUser.sharedInstance.isIncompleteProfile())

        HulaUser.sharedInstance.userName = ""
        XCTAssertTrue(HulaUser.sharedInstance.isIncompleteProfile())

        fillCompleteProfile()
        HulaUser.sharedInstance.userNick = ""
        XCTAssertTrue(HulaUser.sharedInstance.isIncompleteProfile())

        fillCompleteProfile()
        HulaUser.sharedInstance.userBio = ""
        XCTAssertTrue(HulaUser.sharedInstance.isIncompleteProfile())

        fillCompleteProfile()
        HulaUser.sharedInstance.userPhotoURL = ""
        XCTAssertTrue(HulaUser.sharedInstance.isIncompleteProfile())
    }

    func testPopulateUserMapsServerDictionaryFields() {
        let user = HulaUser.sharedInstance
        let payload: NSDictionary = [
            "_id": "user-123",
            "name": "Jane Appleseed",
            "nick": "jane",
            "bio": "trader",
            "email": "jane@example.com",
            "image": "https://hula.trading/files/user/jane.jpg",
            "location": [CGFloat(37.7793), CGFloat(-122.4192)],
            "location_name": "San Francisco",
            "fb_token": "fb-token",
            "tw_token": "tw-token",
            "li_token": "li-token",
            "status": "active",
            "zip": "94103",
            "feedback_count": Float(5.0),
            "feedback_points": Float(4.0),
            "trades_started": Float(3.0),
            "trades_finished": Float(2.0),
            "trades_closed": Float(1.0),
            "deviceId": "device-123",
            "max_trades": 7
        ]

        user.populate(with: payload)

        XCTAssertEqual(user.userId, "user-123")
        XCTAssertEqual(user.userName, "Jane Appleseed")
        XCTAssertEqual(user.userNick, "jane")
        XCTAssertEqual(user.userBio, "trader")
        XCTAssertEqual(user.userEmail, "jane@example.com")
        XCTAssertEqual(user.userPhotoURL, "https://hula.trading/files/user/jane.jpg")
        XCTAssertEqual(user.location.coordinate.latitude, 37.7793, accuracy: 0.0001)
        XCTAssertEqual(user.location.coordinate.longitude, -122.4192, accuracy: 0.0001)
        XCTAssertEqual(user.userLocationName, "San Francisco")
        XCTAssertEqual(user.fbToken, "fb-token")
        XCTAssertEqual(user.twToken, "tw-token")
        XCTAssertEqual(user.liToken, "li-token")
        XCTAssertEqual(user.status, "active")
        XCTAssertEqual(user.zip, "94103")
        XCTAssertEqual(user.feedback_count, Float(5.0))
        XCTAssertEqual(user.feedback_points, Float(4.0))
        XCTAssertEqual(user.trades_started, Float(3.0))
        XCTAssertEqual(user.trades_finished, Float(2.0))
        XCTAssertEqual(user.trades_closed, Float(1.0))
        XCTAssertEqual(user.deviceId, "device-123")
        XCTAssertEqual(user.maxTrades, 7)
    }

    func testThumbnailURLMappingHandlesFallbacksAndNestedImagePaths() {
        let utils = CommonUtils.sharedInstance

        XCTAssertEqual(utils.getThumbFor(url: ""), HulaConstants.noProductThumb)
        XCTAssertEqual(utils.getThumbFor(url: HulaConstants.transparentImg), HulaConstants.transparentImg)
        XCTAssertEqual(
            utils.getThumbFor(url: "https://hula.trading/files/products/product-1/photo.jpg"),
            "https://hula.trading/files/products/product-1/tm_photo.jpg"
        )
        XCTAssertEqual(
            utils.getThumbFor(url: "https://hula.trading/files/a/b/c/item.png"),
            "https://hula.trading/files/a/b/c/tm_item.png"
        )
    }

    func testISO8601ExtensionRoundTripsUTCDate() {
        let date = Date(timeIntervalSince1970: 1_489_842_000.123)
        let encoded = date.iso8601
        guard let decoded = encoded.dateFromISO8601 else {
            XCTFail("Expected ISO8601 formatter to parse its own output")
            return
        }

        XCTAssertEqual(decoded.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 0.001)
    }

    func testLegacyISODateParserReadsServerMillisecondsFormat() {
        let date = CommonUtils.sharedInstance.isoDateToNSDate(date: "2020-01-15T12:34:56.000Z")
        let components = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date as Date)

        XCTAssertEqual(components.year, 2020)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 12)
        XCTAssertEqual(components.minute, 34)
        XCTAssertEqual(components.second, 56)
    }

    func testTradePostStringIncludesCorePayloadFields() {
        let trade = HulaTrade()
        trade.product_id = "product-1"
        trade.owner_id = "owner-1"
        trade.other_id = "other-1"
        trade.date = Date(timeIntervalSince1970: 1_489_842_000.0)
        trade.owner_products = ["owner-product-a", "owner-product-b"]
        trade.other_products = ["other-product-a"]
        trade.next_bid = "other-1"
        trade.status = HulaConstants.sent_status
        trade.turn_user_id = "owner-1"
        trade.owner_money = 12.5
        trade.other_money = 3.0

        let postString = trade.get_post_string()

        XCTAssertTrue(postString.contains("product_id=product-1"))
        XCTAssertTrue(postString.contains("owner_id=owner-1"))
        XCTAssertTrue(postString.contains("other_id=other-1"))
        XCTAssertTrue(postString.contains("date=\(trade.date.iso8601)"))
        XCTAssertTrue(postString.contains("owner_products=owner-product-aowner-product-b"))
        XCTAssertTrue(postString.contains("other_products=other-product-a"))
        XCTAssertTrue(postString.contains("next_bid=other-1"))
        XCTAssertTrue(postString.contains("status=\(HulaConstants.sent_status)"))
        XCTAssertTrue(postString.contains("turn_user_id=owner-1"))
        XCTAssertTrue(postString.contains("owner_money=12.5"))
        XCTAssertTrue(postString.contains("other_money=3.0"))
    }

    func testTradeLoadFromMergesLastBidDiffAndDefaultsUnreadAndAcceptedState() {
        let trade = HulaTrade()
        let payload: NSDictionary = [
            "_id": "trade-1",
            "product_id": "product-1",
            "owner_id": "owner-1",
            "other_id": "other-1",
            "other_agree": true,
            "other_ready": true,
            "owner_ready": false,
            "date": "2017-03-22T10:20:00.000Z",
            "last_update": "2017-03-23T11:21:00.000Z",
            "owner_products": ["owner-product-a"],
            "other_products": ["other-product-a"],
            "owner_money": Float(10.0),
            "other_money": Float(4.5),
            "next_bid": "owner-1",
            "status": HulaConstants.pending_status,
            "turn_user_id": "other-1",
            "bids": [
                [
                    "owner_diff": ["ignored-owner-diff"],
                    "other_diff": ["ignored-other-diff"]
                ],
                [
                    "owner_diff": ["owner-added-product"],
                    "other_diff": ["other-added-product", "other-added-money"]
                ]
            ]
        ]

        trade.loadFrom(dict: payload)

        XCTAssertEqual(trade.tradeId, "trade-1")
        XCTAssertEqual(trade.product_id, "product-1")
        XCTAssertEqual(trade.owner_id, "owner-1")
        XCTAssertEqual(trade.other_id, "other-1")
        XCTAssertTrue(trade.other_agree)
        XCTAssertTrue(trade.other_ready)
        XCTAssertFalse(trade.owner_ready)
        XCTAssertEqual(trade.owner_products, ["owner-product-a"])
        XCTAssertEqual(trade.other_products, ["other-product-a"])
        XCTAssertEqual(trade.owner_money, Float(10.0))
        XCTAssertEqual(trade.other_money, Float(4.5))
        XCTAssertEqual(trade.next_bid, "owner-1")
        XCTAssertEqual(trade.status, HulaConstants.pending_status)
        XCTAssertEqual(trade.turn_user_id, "other-1")
        XCTAssertEqual(trade.owner_unread, 0)
        XCTAssertEqual(trade.other_unread, 0)
        XCTAssertFalse(trade.owner_accepted)
        XCTAssertFalse(trade.other_accepted)
        XCTAssertEqual(trade.num_bids, 2)
        XCTAssertEqual(trade.last_bid_diff, ["owner-added-product", "other-added-product", "other-added-money"])
    }

    private func fillCompleteProfile() {
        let user = HulaUser.sharedInstance
        user.userName = "Jane Appleseed"
        user.userNick = "jane"
        user.userBio = "trader"
        user.userPhotoURL = "https://hula.trading/files/user/jane.jpg"
    }

    private func resetSharedUser() {
        let user = HulaUser.sharedInstance
        user.userId = ""
        user.userName = ""
        user.userNick = ""
        user.userEmail = ""
        user.userPhotoURL = ""
        user.userLocationName = ""
        user.userBio = ""
        user.userPass = ""
        user.token = ""
        user.status = ""
        user.zip = ""
        user.location = CLLocation(latitude: 0, longitude: 0)
        user.fbToken = ""
        user.twToken = ""
        user.liToken = ""
        user.deviceId = ""
        user.maxTrades = 3
        user.feedback_count = 0.0
        user.feedback_points = 0.0
        user.trades_started = 0.0
        user.trades_finished = 0.0
        user.trades_closed = 0.0
        user.arrayProducts = []
        user.numProducts = 0
    }

}
