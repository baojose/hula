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

        // Non-zero user location: USA → miles, Europe → kilometers.
        HulaUser.sharedInstance.location = CLLocation(latitude: 40.7128, longitude: -74.0060) // NYC
        let nycToPhilly = utils.getDistanceFrom(loc: CLLocation(latitude: 39.9526, longitude: -75.1652))
        XCTAssertTrue(nycToPhilly.contains(NSLocalizedString("miles", comment: "")), nycToPhilly)
        XCTAssertFalse(nycToPhilly.contains("-"))
        XCTAssertNotEqual(nycToPhilly, "0 miles")

        HulaUser.sharedInstance.location = CLLocation(latitude: 41.3874, longitude: 2.1686) // Barcelona
        let bcnToMadrid = utils.getDistanceFrom(loc: CLLocation(latitude: 40.4168, longitude: -3.7038))
        XCTAssertTrue(bcnToMadrid.contains(NSLocalizedString("kilometers", comment: "")), bcnToMadrid)
        XCTAssertFalse(bcnToMadrid.contains("-"))

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

    func testUserPopulateParsesIntegerFeedbackCounts() {
        let user = HulaUser()
        user.populate(with: [
            "feedback_count": 4,
            "feedback_points": 3,
            "trades_started": 2,
            "trades_finished": 1,
            "trades_closed": 0
        ] as NSDictionary)

        XCTAssertEqual(user.feedback_count, 4)
        XCTAssertEqual(user.feedback_points, 3)
        XCTAssertEqual(user.getFeedback(), "75%")
        XCTAssertEqual(user.trades_started, 2)
        XCTAssertEqual(user.trades_finished, 1)
        XCTAssertEqual(user.trades_closed, 0)
    }

    func testUserPopulateIgnoresBooleanFeedbackCounts() {
        let user = HulaUser()
        user.feedback_count = 5
        user.feedback_points = 4
        user.trades_started = 3

        user.populate(with: [
            "feedback_count": true,
            "feedback_points": false,
            "trades_started": true
        ] as NSDictionary)

        XCTAssertEqual(user.feedback_count, 5)
        XCTAssertEqual(user.feedback_points, 4)
        XCTAssertEqual(user.trades_started, 3)
        XCTAssertEqual(user.getFeedback(), "80%")
    }

    func testTradePostStringJoinsProductIdsAndEncodesDelimiters() {
        let trade = HulaTrade()
        trade.product_id = "prod&1"
        trade.owner_id = "owner=1"
        trade.other_id = "other+1"
        trade.next_bid = "owner"
        trade.status = "pending"
        trade.turn_user_id = "owner=1"
        trade.owner_products = ["p1", "p2"]
        trade.other_products = ["o1"]
        trade.owner_money = 10
        trade.other_money = 5

        let body = trade.get_post_string()
        XCTAssertTrue(body.contains("product_id=prod%261"))
        XCTAssertTrue(body.contains("owner_id=owner%3D1"))
        XCTAssertTrue(body.contains("other_id=other%2B1"))
        XCTAssertTrue(body.contains("owner_products=p1,p2"))
        XCTAssertTrue(body.contains("other_products=o1"))
        XCTAssertFalse(body.contains("owner_products=p1p2"))
        XCTAssertFalse(body.contains("product_id=prod&1"))
        XCTAssertFalse(body.contains("&owner_id=owner=1&"))
    }

    func testTradeMoneyForSideDependsOnViewerRole() {
        let trade = HulaTrade()
        trade.owner_money = 40
        trade.other_money = 15

        XCTAssertEqual(trade.money(forSide: "other", viewerIsOwner: true), 15)
        XCTAssertEqual(trade.money(forSide: "owner", viewerIsOwner: true), 40)
        XCTAssertEqual(trade.money(forSide: "other", viewerIsOwner: false), 40)
        XCTAssertEqual(trade.money(forSide: "owner", viewerIsOwner: false), 15)
    }

    func testProductApplyUploadedImagePadsSlotsAndTrimsTrailingEmpties() {
        let product = HulaProduct()
        product.arrProductPhotoLink = []
        product.productImage = ""

        product.applyUploadedImage(path: "c.jpg", pos: 3)
        XCTAssertEqual(product.arrProductPhotoLink, ["", "", "c.jpg"])
        // First slot is still empty, so hero image stays unset until slot 1 is filled
        // or a later upload finds a non-empty first entry.
        XCTAssertEqual(product.productImage, "")

        product.applyUploadedImage(path: "a.jpg", pos: 1)
        XCTAssertEqual(product.arrProductPhotoLink, ["a.jpg", "", "c.jpg"])
        XCTAssertEqual(product.productImage, "a.jpg")

        product.applyUploadedImage(path: "b.jpg", pos: 2)
        XCTAssertEqual(product.arrProductPhotoLink, ["a.jpg", "b.jpg", "c.jpg"])

        product.applyUploadedImage(path: "ignored.jpg", pos: 0)
        XCTAssertEqual(product.arrProductPhotoLink, ["a.jpg", "b.jpg", "c.jpg"])

        let emptyHero = HulaProduct()
        emptyHero.productImage = ""
        emptyHero.arrProductPhotoLink = []
        emptyHero.applyUploadedImage(path: "solo.jpg", pos: 2)
        XCTAssertEqual(emptyHero.arrProductPhotoLink, ["", "solo.jpg"])
        XCTAssertEqual(emptyHero.productImage, "")
        emptyHero.applyUploadedImage(path: "hero.jpg", pos: 1)
        XCTAssertEqual(emptyHero.productImage, "hero.jpg")
    }

    func testClassifyTradeBucketsCurrentPastAndHidden() {
        let viewer = "me"

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: HulaConstants.pending_status,
                ownerId: viewer,
                turnUserId: viewer,
                viewerId: viewer,
                ownerAccepted: false,
                otherAccepted: false,
                otherAgree: true
            ),
            .current
        )

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: HulaConstants.pending_status,
                ownerId: viewer,
                turnUserId: "someone-else",
                viewerId: viewer,
                ownerAccepted: false,
                otherAccepted: false,
                otherAgree: true
            ),
            .hidden
        )

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: "active",
                ownerId: "other-owner",
                turnUserId: viewer,
                viewerId: viewer,
                ownerAccepted: false,
                otherAccepted: false,
                otherAgree: false
            ),
            .hidden
        )

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: HulaConstants.end_status,
                ownerId: viewer,
                turnUserId: viewer,
                viewerId: viewer,
                ownerAccepted: true,
                otherAccepted: true,
                otherAgree: true
            ),
            .past
        )

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: HulaConstants.review_status,
                ownerId: "other-owner",
                turnUserId: viewer,
                viewerId: viewer,
                ownerAccepted: false,
                otherAccepted: true,
                otherAgree: true
            ),
            .past
        )

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: HulaConstants.cancel_status,
                ownerId: viewer,
                turnUserId: viewer,
                viewerId: viewer,
                ownerAccepted: false,
                otherAccepted: false,
                otherAgree: true
            ),
            .hidden
        )

        XCTAssertEqual(
            HLDataManager.classifyTrade(
                status: "active",
                ownerId: nil,
                turnUserId: viewer,
                viewerId: viewer,
                ownerAccepted: false,
                otherAccepted: false,
                otherAgree: true
            ),
            .hidden
        )
    }

    func testChatDateSectionKeyHandlesShortAndFullDates() {
        XCTAssertNil(CommonUtils.chatDateSectionKey(""))
        XCTAssertEqual(CommonUtils.chatDateSectionKey("2026-07"), "2026-07")
        XCTAssertEqual(
            CommonUtils.chatDateSectionKey("2026-07-27T10:15:00.000Z"),
            "2026-07-27T10"
        )
    }

    func testLocationDisplayNameHandlesMissingParts() {
        XCTAssertEqual(CommonUtils.locationDisplayName(city: nil, country: nil), "")
        XCTAssertEqual(CommonUtils.locationDisplayName(city: "", country: ""), "")
        XCTAssertEqual(CommonUtils.locationDisplayName(city: "Barcelona", country: nil), "Barcelona")
        XCTAssertEqual(CommonUtils.locationDisplayName(city: nil, country: "Spain"), "Spain")
        XCTAssertEqual(CommonUtils.locationDisplayName(city: "Barcelona", country: "Spain"), "Barcelona, Spain")
    }

    func testResetMailPathComponentEncodesUnsafeEmailCharacters() {
        XCTAssertNil(CommonUtils.resetMailPathComponent("a@b"))
        XCTAssertNil(CommonUtils.resetMailPathComponent("   "))
        XCTAssertEqual(
            CommonUtils.resetMailPathComponent("  user+tag@example.com "),
            "user+tag@example.com".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        )
        let spaced = CommonUtils.resetMailPathComponent("user name@example.com")
        XCTAssertNotNil(spaced)
        XCTAssertFalse(spaced!.contains(" "))
    }

    // MARK: - #96 baseline helpers

    func testRelativeDateLabelReturnsEmptyForMissingOrBlankDate() {
        let utils = CommonUtils.sharedInstance
        XCTAssertEqual(utils.relativeDateLabel(fromISO: nil), "")
        XCTAssertEqual(utils.relativeDateLabel(fromISO: ""), "")
    }

    func testRelativeDateLabelReturnsNonEmptyForValidISODate() {
        let utils = CommonUtils.sharedInstance
        let label = utils.relativeDateLabel(fromISO: "2026-07-27T12:00:00.000Z", numericDates: true)
        XCTAssertFalse(label.isEmpty)
    }

    func testClampedTradeIndexPreventsOutOfBounds() {
        let utils = CommonUtils.sharedInstance
        XCTAssertNil(utils.clampedTradeIndex(0, tradeCount: 0))
        XCTAssertEqual(utils.clampedTradeIndex(-1, tradeCount: 3), 0)
        XCTAssertEqual(utils.clampedTradeIndex(0, tradeCount: 3), 0)
        XCTAssertEqual(utils.clampedTradeIndex(2, tradeCount: 3), 2)
        XCTAssertEqual(utils.clampedTradeIndex(9, tradeCount: 3), 2)
    }

    func testProductIdentityPreventsDuplicateCreateTracking() {
        // Mirrors HLMyProductsViewController.newPostModeDesign re-entry guard:
        // complete-profile Done must not append/upload a second product for the same instance.
        var arrayProducts: [HulaProduct] = []
        let newProduct = HulaProduct()
        arrayProducts.append(newProduct)

        let existingIndex = arrayProducts.index(where: { $0 === newProduct })
        XCTAssertEqual(existingIndex, 0)

        let wouldStartSecondCreate = existingIndex == nil
        XCTAssertFalse(wouldStartSecondCreate)
    }

    // MARK: - Novel coverage beyond #95/#96

    func testSearchUserProductSoftParsesMissingOptionalFields() {
        XCTAssertNil(CommonUtils.searchUserProduct(from: ["name": "Ada"] as NSDictionary))

        let partial = CommonUtils.searchUserProduct(from: [
            "_id": "u42",
            "name": "Ada"
        ] as NSDictionary)
        XCTAssertNotNil(partial)
        XCTAssertEqual(partial?.productId, "u42")
        XCTAssertEqual(partial?.productCategoryId, "xx_user")
        XCTAssertEqual(partial?.productDescription, "")
        XCTAssertEqual(partial?.productImage, "")
        XCTAssertTrue(partial!.productName.contains("Ada"))
        XCTAssertTrue(partial!.productName.contains("()"))

        let full = CommonUtils.searchUserProduct(from: [
            "_id": "u7",
            "name": "Grace",
            "nick": "hopper",
            "image": "https://hula.trading/u7.jpg"
        ] as NSDictionary)
        XCTAssertEqual(full?.productDescription, "hopper")
        XCTAssertEqual(full?.productImage, "https://hula.trading/u7.jpg")
        XCTAssertTrue(full!.productName.contains("hopper"))
    }

    func testFeedbackPostStringEncodesDelimitersInComments() {
        let body = CommonUtils.feedbackPostString(
            tradeId: "t+1",
            userId: "u&2",
            comments: "great=deal & more+",
            points: 5
        )
        XCTAssertTrue(body.hasPrefix("trade_id="))
        XCTAssertTrue(body.contains("&user_id="))
        XCTAssertTrue(body.contains("&comments="))
        XCTAssertTrue(body.hasSuffix("&val=5"))
        XCTAssertFalse(body.contains("comments=great=deal & more+"))
        XCTAssertTrue(body.contains(CommonUtils.formEncodedValue("great=deal & more+")))
        XCTAssertTrue(body.contains(CommonUtils.formEncodedValue("t+1")))
        XCTAssertTrue(body.contains(CommonUtils.formEncodedValue("u&2")))
    }

    func testAgreeResponseSucceededGatesOnOkAndObjectBody() {
        XCTAssertFalse(CommonUtils.agreeResponseSucceeded(ok: false, json: ["ok": true]))
        XCTAssertFalse(CommonUtils.agreeResponseSucceeded(ok: true, json: nil))
        XCTAssertFalse(CommonUtils.agreeResponseSucceeded(ok: true, json: "ok"))
        XCTAssertFalse(CommonUtils.agreeResponseSucceeded(ok: true, json: [1, 2]))
        XCTAssertTrue(CommonUtils.agreeResponseSucceeded(ok: true, json: ["status": "ok"] as [String: Any]))
    }

    func testBarterProductIdentityDefaultsMissingTitle() {
        XCTAssertNil(CommonUtils.barterProductIdentity(from: ["title": "Bike"]))
        XCTAssertNil(CommonUtils.barterProductIdentity(from: ["_id": ""]))

        let untitled = CommonUtils.barterProductIdentity(from: ["_id": "p9"])
        XCTAssertEqual(untitled?.id, "p9")
        XCTAssertEqual(untitled?.title, NSLocalizedString("Untitled product", comment: ""))

        let titled = CommonUtils.barterProductIdentity(from: ["_id": "p1", "title": "Lamp"])
        XCTAssertEqual(titled?.id, "p1")
        XCTAssertEqual(titled?.title, "Lamp")
    }

    func testPlayableVideoURLRejectsMissingBlankAndMalformed() {
        XCTAssertNil(CommonUtils.playableVideoURL(videoURLs: [:], tradeId: "t1"))
        XCTAssertNil(CommonUtils.playableVideoURL(videoURLs: ["t1": ""], tradeId: "t1"))
        XCTAssertNil(CommonUtils.playableVideoURL(videoURLs: ["other": "https://hula.trading/v.mp4"], tradeId: "t1"))

        let url = CommonUtils.playableVideoURL(
            videoURLs: ["t1": "https://hula.trading/files/video.mp4"],
            tradeId: "t1"
        )
        XCTAssertEqual(url?.absoluteString, "https://hula.trading/files/video.mp4")
    }

}
