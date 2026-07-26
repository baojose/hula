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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func assertLocation(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.000000001, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.000000001, file: file, line: line)
    }
    
    func testProductPopulateAcceptsPreciseNumericLocationPayloads() {
        let product = HulaProduct()

        product.populate(with: [
            "location": [
                NSNumber(value: 41.387123456),
                NSNumber(value: 2.168987654)
            ]
        ])

        assertLocation(product.productLocation, latitude: 41.387123456, longitude: 2.168987654)
    }

    func testProductPopulateAcceptsBridgedNSArrayLocationPayloads() {
        let product = HulaProduct()

        product.populate(with: [
            "location": NSArray(array: [
                NSNumber(value: 12.5),
                NSNumber(value: -70.25)
            ])
        ])

        assertLocation(product.productLocation, latitude: 12.5, longitude: -70.25)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayloads() {
        let product = HulaProduct()

        product.populate(with: [
            "location": [Float(51.5074), -1] as [Any]
        ])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -1.0, accuracy: 0.000000001)
    }

    func testProductPopulatePreservesLocationForMalformedPayloads() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": [NSNumber(value: 99.0)]])
        assertLocation(product.productLocation, latitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": [true, NSNumber(value: -30.0)]])
        assertLocation(product.productLocation, latitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": "not coordinates"])
        assertLocation(product.productLocation, latitude: 10.25, longitude: -20.5)
    }

    func testProductPopulateSkipsEmptyImageURLs() {
        let product = HulaProduct()
        product.arrProductPhotoLink = ["stale.jpg"]

        product.populate(with: [
            "images": ["https://hula.trading/a.jpg", "", "https://hula.trading/b.jpg"]
        ])

        XCTAssertEqual(product.arrProductPhotoLink, [
            "https://hula.trading/a.jpg",
            "https://hula.trading/b.jpg"
        ])
    }

    func testUserPopulateAcceptsPreciseNumericLocationPayloads() {
        let user = HulaUser()

        user.populate(with: [
            "location": [
                NSNumber(value: -33.865143),
                NSNumber(value: 151.2099)
            ]
        ])

        assertLocation(user.location, latitude: -33.865143, longitude: 151.2099)
    }

    func testUserPopulatePreservesLocationForMalformedPayloads() {
        let user = HulaUser()
        user.location = CLLocation(latitude: 1.5, longitude: 2.5)

        user.populate(with: ["location": [] as [Any]])
        assertLocation(user.location, latitude: 1.5, longitude: 2.5)

        user.populate(with: ["location": [NSNumber(value: true), NSNumber(value: 4.0)]])
        assertLocation(user.location, latitude: 1.5, longitude: 2.5)

        user.populate(with: ["location": ["north", "west"]])
        assertLocation(user.location, latitude: 1.5, longitude: 2.5)
    }

    func testUserLoginAndFeedbackHelpers() {
        let user = HulaUser()
        XCTAssertFalse(user.isUserLoggedIn())
        XCTAssertEqual(user.getFeedback(), "-")

        user.userId = "user-1"
        user.token = "token-1"
        XCTAssertTrue(user.isUserLoggedIn())

        user.feedback_count = 4
        user.feedback_points = 3
        XCTAssertEqual(user.getFeedback(), "75%")
    }

    func testUserIncompleteProfileRequiresCoreFields() {
        let user = HulaUser()
        XCTAssertTrue(user.isIncompleteProfile())

        user.userName = "Ada"
        user.userNick = "ada"
        user.userBio = "Swaps gear"
        user.userPhotoURL = "https://hula.trading/ada.jpg"
        XCTAssertFalse(user.isIncompleteProfile())

        user.userBio = ""
        XCTAssertTrue(user.isIncompleteProfile())
    }

    func testTradeLoadFromHandlesEmptyBidsWithoutStaleDiffs() {
        let trade = HulaTrade()
        trade.num_bids = 2
        trade.last_bid_diff = ["stale-owner", "stale-other"]

        trade.loadFrom(dict: ["bids": [] as [Any]])

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertTrue(trade.last_bid_diff.isEmpty)
    }

    func testTradeLoadFromClearsBidStateWhenBidsAreAbsent() {
        let trade = HulaTrade()
        trade.num_bids = 1
        trade.last_bid_diff = ["stale"]

        trade.loadFrom(dict: NSDictionary())

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertTrue(trade.last_bid_diff.isEmpty)
    }

    func testTradeLoadFromUsesLatestBidDiffs() {
        let trade = HulaTrade()

        trade.loadFrom(dict: [
            "bids": [
                [
                    "owner_diff": ["old-owner"],
                    "other_diff": ["old-other"]
                ],
                [
                    "owner_diff": ["owner-a", "owner-b"],
                    "other_diff": ["other-a"]
                ]
            ]
        ])

        XCTAssertEqual(trade.num_bids, 2)
        XCTAssertEqual(trade.last_bid_diff, ["owner-a", "owner-b", "other-a"])
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

    func testFloatFromJSONAcceptsWholeNumberIntegers() {
        let intValue: Any = NSNumber(value: 50)
        XCTAssertEqual(CommonUtils.floatFromJSON(intValue), 50)
        XCTAssertEqual(CommonUtils.floatFromJSON(50 as Int), 50)
    }

    func testFloatFromJSONAcceptsFloatingPointNumbers() {
        XCTAssertEqual(CommonUtils.floatFromJSON(NSNumber(value: 12.5)), 12.5)
        XCTAssertEqual(CommonUtils.floatFromJSON(7.25 as Double), 7.25)
        XCTAssertEqual(CommonUtils.floatFromJSON(Float(3.5)), 3.5)
    }

    func testFloatFromJSONRejectsBooleans() {
        XCTAssertNil(CommonUtils.floatFromJSON(true))
        XCTAssertNil(CommonUtils.floatFromJSON(false))
        XCTAssertNil(CommonUtils.floatFromJSON(NSNumber(value: true)))
    }

    func testTradeLoadFromParsesIntegerCashAmounts() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "owner_money": 50,
            "other_money": 25
        ] as NSDictionary)

        XCTAssertEqual(trade.owner_money, 50)
        XCTAssertEqual(trade.other_money, 25)
    }

    func testTradeLoadFromParsesFloatingCashAmounts() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "owner_money": NSNumber(value: 12.5),
            "other_money": NSNumber(value: 0.0)
        ] as NSDictionary)

        XCTAssertEqual(trade.owner_money, 12.5)
        XCTAssertEqual(trade.other_money, 0)
    }

    func testTradeLoadFromIgnoresBooleanCashAmounts() {
        let trade = HulaTrade()
        trade.owner_money = 9
        trade.other_money = 8
        trade.loadFrom(dict: [
            "owner_money": true,
            "other_money": false
        ] as NSDictionary)

        XCTAssertEqual(trade.owner_money, 9)
        XCTAssertEqual(trade.other_money, 8)
    }

    func testFormEncodedValueEncodesPlusAmpersandAndEquals() {
        let email = CommonUtils.formEncodedValue("user+tag@gmail.com")
        XCTAssertEqual(email, "user%2Btag@gmail.com")
        XCTAssertFalse(email.contains("+"))

        let password = CommonUtils.formEncodedValue("a&b=c+d")
        XCTAssertEqual(password, "a%26b%3Dc%2Bd")
        XCTAssertFalse(password.contains("&"))
        XCTAssertFalse(password.contains("="))
        XCTAssertFalse(password.contains("+"))
    }

    func testFormEncodedValueLeavesDelimitersToCaller() {
        let body = "email=" + CommonUtils.formEncodedValue("a+b@c.com")
            + "&pass=" + CommonUtils.formEncodedValue("x&y=z")
        XCTAssertTrue(body.hasPrefix("email="))
        XCTAssertTrue(body.contains("&pass="))
        XCTAssertTrue(body.contains("email=a%2Bb@c.com"))
        XCTAssertTrue(body.contains("pass=x%26y%3Dz"))
        XCTAssertFalse(body.contains("email=a+b@c.com"))
        XCTAssertFalse(body.contains("&pass=x&y=z"))
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
        user.userEmail = "a+b@c.com"
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
        XCTAssertTrue(body.contains("email=a%2Bb@c.com"))
        XCTAssertTrue(body.contains("name=Ann%20%26%20Bob"))
        XCTAssertTrue(body.contains("bio=likes%20A%26B"))
        XCTAssertTrue(body.contains("image=https://example.com/u.jpg?x%3D1%26y%3D2"))
        XCTAssertFalse(body.contains("email=a+b@c.com"))
        XCTAssertFalse(body.contains("name=Ann & Bob"))
        XCTAssertFalse(body.contains("&bio=likes A&B&"))
    }

    func testCommonUtilsThumbAndDistanceHelpers() {
        let utils = CommonUtils.sharedInstance

        XCTAssertEqual(utils.getThumbFor(url: ""), HulaConstants.noProductThumb)
        XCTAssertEqual(utils.getThumbFor(url: HulaConstants.transparentImg), HulaConstants.transparentImg)
        XCTAssertEqual(
            utils.getThumbFor(url: "https://hula.trading/files/product/photo.jpg"),
            "https://hula.trading/files/product/tm_photo.jpg"
        )

        XCTAssertTrue(utils.inUSA(CLLocation(latitude: 40.7, longitude: -74.0)))
        XCTAssertFalse(utils.inUSA(CLLocation(latitude: 41.4, longitude: 2.2)))

        let previousLocation = HulaUser.sharedInstance.location
        HulaUser.sharedInstance.location = CLLocation(latitude: 0, longitude: 0)
        XCTAssertEqual(utils.getDistanceFrom(loc: CLLocation(latitude: 40.7, longitude: -74.0)), "-")
        HulaUser.sharedInstance.location = previousLocation
    }

    func testPublicSocialCredentialPlaceholdersRemainSanitized() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedInClientId, "")
        XCTAssertEqual(HulaConstants.linkedInClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedInState, "")
        XCTAssertEqual(HulaConstants.linkedInRedirectURL, "https://hula.trading/")
    }
    
}
