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

    // MARK: - Novel coverage beyond #97/#98

    func testProductPostStringUsesProductLocationNotUserGPS() {
        let product = HulaProduct()
        product.productId = "prod-1"
        product.productName = "Lamp"
        product.productDescription = "Desk lamp"
        product.productCondition = "good"
        product.productCategory = "Home"
        product.productCategoryId = "cat-1"
        product.productImage = "https://example.com/lamp.jpg"
        product.productOwner = "owner-1"
        product.arrProductPhotoLink = ["https://example.com/lamp.jpg"]
        product.productLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)

        let previousUserLocation = HulaUser.sharedInstance.location
        HulaUser.sharedInstance.location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        defer { HulaUser.sharedInstance.location = previousUserLocation }

        let body = product.getPostString()
        XCTAssertTrue(body.contains("lat=40.7128"), "Edit PUT must keep product lat; got \(body)")
        XCTAssertTrue(body.contains("lng=-74.006"), "Edit PUT must keep product lng; got \(body)")
        XCTAssertFalse(body.contains("lat=37.7749"), "Must not overwrite with user GPS; got \(body)")
        XCTAssertFalse(body.contains("lng=-122.4194"), "Must not overwrite with user GPS; got \(body)")
    }

    func testProductPostStringOmitsZeroCoordinates() {
        let product = HulaProduct()
        product.productName = "Untitled"
        product.productDescription = ""
        product.productCondition = ""
        product.productCategory = ""
        product.productCategoryId = ""
        product.productImage = ""
        product.productOwner = ""
        product.arrProductPhotoLink = []
        product.productLocation = CLLocation(latitude: 0, longitude: 0)

        let previousUserLocation = HulaUser.sharedInstance.location
        HulaUser.sharedInstance.location = CLLocation(latitude: 51.5074, longitude: -0.1278)
        defer { HulaUser.sharedInstance.location = previousUserLocation }

        let body = product.getPostString()
        XCTAssertFalse(body.contains("&lat="), "Unset product location must not send lat; got \(body)")
        XCTAssertFalse(body.contains("&lng="), "Unset product location must not send lng; got \(body)")
    }

    func testSyncFeaturedImageClearsWhenPhotosEmpty() {
        let product = HulaProduct()
        product.productImage = "https://example.com/old.jpg"
        product.arrProductPhotoLink = []
        product.syncFeaturedImageFromPhotos()
        XCTAssertEqual(product.productImage, "")

        let body = product.getPostString()
        XCTAssertTrue(body.contains("image_url="), body)
        XCTAssertFalse(
            body.contains("image_url=" + CommonUtils.formEncodedValue("https://example.com/old.jpg")),
            "Deleted photo must not remain as featured image_url; got \(body)"
        )

        product.arrProductPhotoLink = ["https://example.com/new.jpg"]
        product.syncFeaturedImageFromPhotos()
        XCTAssertEqual(product.productImage, "https://example.com/new.jpg")
    }

    func testIntFromJSONAcceptsWholeAndBridgedNumbers() {
        XCTAssertEqual(CommonUtils.intFromJSON(3), 3)
        XCTAssertEqual(CommonUtils.intFromJSON(NSNumber(value: 7)), 7)
        XCTAssertEqual(CommonUtils.intFromJSON(4.0), 4)
        XCTAssertEqual(CommonUtils.intFromJSON(Float(2)), 2)
        XCTAssertNil(CommonUtils.intFromJSON(true))
        XCTAssertNil(CommonUtils.intFromJSON(false))
        XCTAssertNil(CommonUtils.intFromJSON("3"))
        XCTAssertNil(CommonUtils.intFromJSON(nil))
    }

    func testTradeLoadFromParsesBridgedUnreadCounts() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "_id": "t1",
            "owner_unread": NSNumber(value: 2),
            "other_unread": 5.0
        ] as NSDictionary)
        XCTAssertEqual(trade.owner_unread, 2)
        XCTAssertEqual(trade.other_unread, 5)

        trade.loadFrom(dict: [
            "_id": "t2",
            "owner_unread": true,
            "other_unread": "1"
        ] as NSDictionary)
        XCTAssertEqual(trade.owner_unread, 0)
        XCTAssertEqual(trade.other_unread, 0)
    }

    // MARK: - Novel coverage beyond #99/#100

    /// Profile/settings PUT must not send blank optional credentials after cold start.
    func testUserPostStringOmitsEmptyOptionalCredentials() {
        let user = HulaUser()
        user.userEmail = "a@b.com"
        user.userName = "Ann"
        user.userBio = ""
        user.userNick = "ann"
        user.userPhotoURL = ""
        user.twToken = ""
        user.liToken = ""
        user.fbToken = ""
        user.deviceId = ""
        user.zip = ""
        user.maxTrades = 2

        let body = user.getPostString()
        XCTAssertTrue(body.contains("email=a@b.com"), body)
        XCTAssertTrue(body.contains("max_trades=2"), body)
        XCTAssertFalse(body.contains("twtoken="), "Empty twtoken must be omitted; got \(body)")
        XCTAssertFalse(body.contains("litoken="), "Empty litoken must be omitted; got \(body)")
        XCTAssertFalse(body.contains("fbtoken="), "Empty fbtoken must be omitted; got \(body)")
        XCTAssertFalse(body.contains("push_device_id="), "Empty push id must be omitted; got \(body)")
        XCTAssertFalse(body.contains("&zip="), "Empty zip must be omitted; got \(body)")
        XCTAssertFalse(body.contains("&image="), "Empty image must be omitted; got \(body)")
    }

    func testUserPostStringIncludesNonEmptyOptionalCredentials() {
        let user = HulaUser()
        user.userEmail = "a@b.com"
        user.userName = "Ann"
        user.userBio = "hi"
        user.userNick = "ann"
        user.userPhotoURL = "https://example.com/u.jpg"
        user.twToken = "tw"
        user.liToken = "li"
        user.fbToken = "fb"
        user.deviceId = "device-9"
        user.zip = "10001"
        user.maxTrades = 3

        let body = user.getPostString()
        XCTAssertTrue(body.contains("twtoken=tw"), body)
        XCTAssertTrue(body.contains("litoken=li"), body)
        XCTAssertTrue(body.contains("fbtoken=fb"), body)
        XCTAssertTrue(body.contains("push_device_id=device-9"), body)
        XCTAssertTrue(body.contains("zip=10001"), body)
        XCTAssertTrue(body.contains("image=" + CommonUtils.formEncodedValue("https://example.com/u.jpg")), body)
    }

    func testUserPopulateAcceptsAlternateTokenAndPushKeys() {
        let user = HulaUser()
        user.populate(with: [
            "_id": "u1",
            "fbtoken": "fb-alt",
            "twtoken": "tw-alt",
            "litoken": "li-alt",
            "push_device_id": "push-1",
            "zip": "90210"
        ] as NSDictionary)
        XCTAssertEqual(user.fbToken, "fb-alt")
        XCTAssertEqual(user.twToken, "tw-alt")
        XCTAssertEqual(user.liToken, "li-alt")
        XCTAssertEqual(user.deviceId, "push-1")
        XCTAssertEqual(user.zip, "90210")
    }

    func testBoolFromJSONAcceptsBoolAndZeroOne() {
        XCTAssertEqual(CommonUtils.boolFromJSON(true), true)
        XCTAssertEqual(CommonUtils.boolFromJSON(false), false)
        XCTAssertEqual(CommonUtils.boolFromJSON(NSNumber(value: true)), true)
        XCTAssertEqual(CommonUtils.boolFromJSON(NSNumber(value: false)), false)
        XCTAssertEqual(CommonUtils.boolFromJSON(NSNumber(value: 1)), true)
        XCTAssertEqual(CommonUtils.boolFromJSON(NSNumber(value: 0)), false)
        XCTAssertEqual(CommonUtils.boolFromJSON(1), true)
        XCTAssertEqual(CommonUtils.boolFromJSON(0), false)
        XCTAssertNil(CommonUtils.boolFromJSON(NSNumber(value: 2)))
        XCTAssertNil(CommonUtils.boolFromJSON(NSNumber(value: -1)))
        XCTAssertNil(CommonUtils.boolFromJSON("true"))
        XCTAssertNil(CommonUtils.boolFromJSON(nil))
    }

    func testTradeLoadFromParsesBridgedAcceptanceFlags() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "_id": "t1",
            "owner_accepted": NSNumber(value: 1),
            "other_accepted": 0,
            "other_agree": true,
            "owner_ready": NSNumber(value: false),
            "other_ready": NSNumber(value: 1)
        ] as NSDictionary)
        XCTAssertTrue(trade.owner_accepted)
        XCTAssertFalse(trade.other_accepted)
        XCTAssertTrue(trade.other_agree)
        XCTAssertFalse(trade.owner_ready)
        XCTAssertTrue(trade.other_ready)

        trade.loadFrom(dict: [
            "_id": "t2",
            "owner_accepted": NSNumber(value: 2),
            "other_accepted": "yes",
            "other_agree": NSNumber(value: -1)
        ] as NSDictionary)
        XCTAssertFalse(trade.owner_accepted)
        XCTAssertFalse(trade.other_accepted)
        // malformed other_agree leaves prior value unchanged (same soft-parse pattern as money)
        XCTAssertTrue(trade.other_agree)
    }

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

    // MARK: - Novel coverage beyond #101/#100/#102

    /// getTrades must soft-parse 0/1 acceptance flags and skip malformed rows without crashing.
    func testPartitionTradesHidesAcceptedRoomsWithBridgedBoolFlags() {
        let me = "me"
        let trades: [NSDictionary] = [
            [
                "_id": "active-open",
                "status": "active",
                "owner_id": me,
                "turn_user_id": me,
                "owner_accepted": 0,
                "other_accepted": 0,
                "other_agree": 1
            ],
            [
                "_id": "owner-accepted",
                "status": "active",
                "owner_id": me,
                "turn_user_id": me,
                "owner_accepted": NSNumber(value: 1),
                "other_accepted": 0,
                "other_agree": true
            ],
            [
                "_id": "other-declined",
                "status": "active",
                "owner_id": "seller",
                "turn_user_id": me,
                "owner_accepted": false,
                "other_accepted": 0,
                "other_agree": NSNumber(value: 0)
            ],
            [
                "_id": "ended",
                "status": HulaConstants.end_status,
                "owner_id": me,
                "turn_user_id": me,
                "owner_accepted": true,
                "other_accepted": true,
                "other_agree": true
            ],
            [
                "_id": "malformed-owner",
                "status": "active",
                "owner_id": NSNull(),
                "turn_user_id": me
            ]
        ]

        let partitioned = HLDataManager.partitionTrades(trades, userId: me)
        XCTAssertEqual(partitioned.all.count, 5)
        XCTAssertEqual(partitioned.current.count, 1)
        XCTAssertEqual(partitioned.current.first?.object(forKey: "_id") as? String, "active-open")
        XCTAssertEqual(partitioned.past.count, 1)
        XCTAssertEqual(partitioned.past.first?.object(forKey: "_id") as? String, "ended")
    }

    func testMyRoomsFullUsesPublishedCurrentCount() {
        let user = HulaUser.sharedInstance
        let previousMax = user.maxTrades
        let previousId = user.userId
        let dm = HLDataManager.sharedInstance
        let previousAll = dm.arrTrades
        let previousCurrent = dm.arrCurrentTrades
        let previousPast = dm.arrPastTrades
        defer {
            user.maxTrades = previousMax
            user.userId = previousId
            dm.arrTrades = previousAll
            dm.arrCurrentTrades = previousCurrent
            dm.arrPastTrades = previousPast
        }

        user.userId = "me"
        user.maxTrades = 2
        let trades: [NSDictionary] = [
            [
                "_id": "r1",
                "status": "active",
                "owner_id": "me",
                "turn_user_id": "me",
                "owner_accepted": false,
                "other_accepted": false,
                "other_agree": true
            ],
            [
                "_id": "r2",
                "status": "active",
                "owner_id": "me",
                "turn_user_id": "me",
                "owner_accepted": false,
                "other_accepted": false,
                "other_agree": true
            ]
        ]
        let partitioned = HLDataManager.partitionTrades(trades, userId: "me")
        dm.arrTrades = partitioned.all
        dm.arrCurrentTrades = partitioned.current
        dm.arrPastTrades = partitioned.past
        XCTAssertTrue(dm.myRoomsFull())

        dm.arrCurrentTrades = Array(partitioned.current.prefix(1))
        XCTAssertFalse(dm.myRoomsFull())
    }

    func testAmITradingWithSoftParsesParticipantIds() {
        let dm = HLDataManager.sharedInstance
        let previous = dm.arrCurrentTrades
        defer { dm.arrCurrentTrades = previous }

        dm.arrCurrentTrades = [
            [
                "_id": "t1",
                "owner_id": "alice",
                "other_id": NSNull()
            ] as NSDictionary,
            [
                "_id": "t2",
                "owner_id": "bob",
                "other_id": "carol"
            ] as NSDictionary
        ]
        XCTAssertTrue(dm.amITradingWith("alice"))
        XCTAssertTrue(dm.amITradingWith("carol"))
        XCTAssertFalse(dm.amITradingWith("dave"))
    }

    /// UserData.plist must round-trip optional credentials across cold start.
    func testUserSessionCredentialSnapshotIncludesOptionalFields() {
        let user = HulaUser()
        user.zip = "10001"
        user.fbToken = "fb"
        user.twToken = "tw"
        user.liToken = "li"
        user.deviceId = "device-1"
        user.status = "active"

        let snapshot = HLDataManager.userSessionCredentialSnapshot(from: user)
        XCTAssertEqual(snapshot["zip"], "10001")
        XCTAssertEqual(snapshot["fbToken"], "fb")
        XCTAssertEqual(snapshot["twToken"], "tw")
        XCTAssertEqual(snapshot["liToken"], "li")
        XCTAssertEqual(snapshot["deviceId"], "device-1")
        XCTAssertEqual(snapshot["status"], "active")
    }

    func testApplyUserSessionCredentialsAcceptsAlternateKeys() {
        let user = HulaUser()
        HLDataManager.applyUserSessionCredentials(to: user, from: [
            "zip": "90210",
            "status": "verified",
            "fbtoken": "fb-alt",
            "tw_token": "tw-alt",
            "litoken": "li-alt",
            "push_device_id": "push-9"
        ] as NSDictionary)
        XCTAssertEqual(user.zip, "90210")
        XCTAssertEqual(user.status, "verified")
        XCTAssertEqual(user.fbToken, "fb-alt")
        XCTAssertEqual(user.twToken, "tw-alt")
        XCTAssertEqual(user.liToken, "li-alt")
        XCTAssertEqual(user.deviceId, "push-9")
    }

    func testResolvedFacebookTokenFallsBackToLoginToken() {
        XCTAssertEqual(
            HLDataManager.resolvedFacebookToken(currentFbToken: "kept", loginToken: "login"),
            "kept"
        )
        XCTAssertEqual(
            HLDataManager.resolvedFacebookToken(currentFbToken: "", loginToken: "login-fb"),
            "login-fb"
        )
    }

    func testUpdateUserFromDictRestoresCredentialsAndSoftMaxTrades() {
        let user = HulaUser.sharedInstance
        let previousZip = user.zip
        let previousFb = user.fbToken
        let previousTw = user.twToken
        let previousLi = user.liToken
        let previousDevice = user.deviceId
        let previousStatus = user.status
        let previousMax = user.maxTrades
        let previousNum = user.numProducts
        let previousId = user.userId
        defer {
            user.zip = previousZip
            user.fbToken = previousFb
            user.twToken = previousTw
            user.liToken = previousLi
            user.deviceId = previousDevice
            user.status = previousStatus
            user.maxTrades = previousMax
            user.numProducts = previousNum
            user.userId = previousId
        }

        user.logout()
        HLDataManager.sharedInstance.updateUserFromDict(dict: [
            "_id": "user-42",
            "max_trades": NSNumber(value: 5.0),
            "numProducts": 7,
            "zip": "30301",
            "fb_token": "fb-from-api",
            "twtoken": "tw-from-api",
            "liToken": "li-from-api",
            "deviceId": "dev-from-plist",
            "status": "ok"
        ] as NSDictionary)

        XCTAssertEqual(user.userId, "user-42")
        XCTAssertEqual(user.maxTrades, 5)
        XCTAssertEqual(user.numProducts, 7)
        XCTAssertEqual(user.zip, "30301")
        XCTAssertEqual(user.fbToken, "fb-from-api")
        XCTAssertEqual(user.twToken, "tw-from-api")
        XCTAssertEqual(user.liToken, "li-from-api")
        XCTAssertEqual(user.deviceId, "dev-from-plist")
        XCTAssertEqual(user.status, "ok")

        // Bool must not collapse into max_trades=1.
        let maxBeforeBool = user.maxTrades
        HLDataManager.sharedInstance.updateUserFromDict(dict: [
            "max_trades": true
        ] as NSDictionary)
        XCTAssertEqual(user.maxTrades, maxBeforeBool)
    }

    // MARK: - Beyond #103/#104: categories, session clear, room count, soft trade lookup

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
        XCTAssertEqual(HLDataManager.categories(from: "string").count, 0)
    }

    func testClearSessionCachesDropsTradesAndNotifications() {
        let dm = HLDataManager.sharedInstance
        let previousTrades = dm.arrTrades
        let previousCurrent = dm.arrCurrentTrades
        let previousPast = dm.arrPastTrades
        let previousNotes = dm.arrNotifications
        let previousPending = dm.numNotificationsPending
        let previousLoading = dm.isLoadingNotifications
        let previousSwap = dm.isInSwapVC
        defer {
            dm.arrTrades = previousTrades
            dm.arrCurrentTrades = previousCurrent
            dm.arrPastTrades = previousPast
            dm.arrNotifications = previousNotes
            dm.numNotificationsPending = previousPending
            dm.isLoadingNotifications = previousLoading
            dm.isInSwapVC = previousSwap
        }

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
        XCTAssertEqual(HLDashboardViewController.tradeRoomCount(tradeCount: 2, maxTrades: 0), 2)
    }

    /// Malformed participant/_id rows must not crash when opening an existing room.
    func testGetTradeWithSoftParsesParticipantIdsAndAgreeFlags() {
        let dm = HLDataManager.sharedInstance
        let previousCurrent = dm.arrCurrentTrades
        let previousAll = dm.arrTrades
        defer {
            dm.arrCurrentTrades = previousCurrent
            dm.arrTrades = previousAll
        }

        dm.arrCurrentTrades = [
            [
                "_id": "cur-1",
                "owner_id": NSNull(),
                "other_id": "carol"
            ] as NSDictionary,
            [
                "_id": "cur-2",
                "owner_id": "alice",
                "other_id": "bob"
            ] as NSDictionary
        ]
        dm.arrTrades = [
            [
                "_id": "offer-1",
                "owner_id": "dave",
                "other_agree": 0,
                "status": HulaConstants.sent_status
            ] as NSDictionary,
            [
                "_id": "offer-bad",
                "owner_id": "erin",
                "other_agree": true,
                "status": HulaConstants.sent_status
            ] as NSDictionary,
            [
                "_id": NSNull(),
                "owner_id": "frank",
                "other_agree": 0,
                "status": HulaConstants.pending_status
            ] as NSDictionary
        ]

        XCTAssertEqual(dm.getTradeWith("carol"), "cur-1")
        XCTAssertEqual(dm.getTradeWith("alice"), "cur-2")
        XCTAssertEqual(dm.getTradeWith("dave"), "offer-1")
        XCTAssertEqual(dm.getTradeWith("erin"), "")
        XCTAssertEqual(dm.getTradeWith("frank"), "")
        XCTAssertEqual(dm.getTradeWith("missing"), "")
    }

    /// Offered-trade detection must tolerate NSNull ids and bridged 0/1 agree flags.
    func testAmIOfferedToTradeWithSoftParsesStatusAndAgreeFlags() {
        let dm = HLDataManager.sharedInstance
        let previousCurrent = dm.arrCurrentTrades
        let previousAll = dm.arrTrades
        defer {
            dm.arrCurrentTrades = previousCurrent
            dm.arrTrades = previousAll
        }

        dm.arrCurrentTrades = [
            [
                "_id": "cur-pending",
                "other_id": "peer-a",
                "status": HulaConstants.pending_status
            ] as NSDictionary,
            [
                "_id": "cur-null",
                "other_id": NSNull(),
                "status": HulaConstants.pending_status
            ] as NSDictionary
        ]
        dm.arrTrades = [
            [
                "_id": "offer-open",
                "owner_id": "peer-b",
                "other_agree": 0
            ] as NSDictionary,
            [
                "_id": "offer-closed",
                "owner_id": "peer-c",
                "other_agree": 1
            ] as NSDictionary
        ]

        XCTAssertTrue(dm.amIOfferedToTradeWith("peer-a"))
        XCTAssertTrue(dm.amIOfferedToTradeWith("peer-b"))
        XCTAssertFalse(dm.amIOfferedToTradeWith("peer-c"))
        XCTAssertFalse(dm.amIOfferedToTradeWith("nobody"))
    }

    // MARK: - Beyond #105/#106: notifications, profile expiry, push gate, duplicate trade, search

    func testNotificationsLoadingFlagClearsOnSuccess() {
        XCTAssertFalse(HLDataManager.isLoadingNotifications(afterResponseReceived: true))
    }

    func testNotificationsLoadingFlagClearsOnFailure() {
        // Previously only the success path cleared the flag, so a failed GET left
        // isLoadingNotifications == true and checkIfNotificationsLoaded looped forever.
        XCTAssertFalse(HLDataManager.isLoadingNotifications(afterResponseReceived: false))
    }

    func testNotificationsPayloadFiltersDeletedAndCountsUnread() {
        let json: [Any] = [
            ["_id": "1", "status": "active", "is_read": 0],
            ["_id": "2", "status": "deleted", "is_read": 0],
            ["_id": "3", "status": "active", "is_read": 1],
            ["_id": "4", "status": "active", "is_read": NSNumber(value: 0)]
        ]
        let payload = HLDataManager.notificationsPayload(from: json)
        XCTAssertEqual(payload.items.count, 3)
        XCTAssertEqual(payload.pending, 2)
    }

    func testNotificationsPayloadHandlesNilAndMalformed() {
        let empty = HLDataManager.notificationsPayload(from: nil)
        XCTAssertEqual(empty.items.count, 0)
        XCTAssertEqual(empty.pending, 0)

        let bad = HLDataManager.notificationsPayload(from: ["not": "an array"])
        XCTAssertEqual(bad.items.count, 0)
        XCTAssertEqual(bad.pending, 0)
    }

    func testCanPublishLiveBarterRequiresBothFetches() {
        XCTAssertFalse(HLBarterScreenViewController.canPublishLiveBarter(
            ownerFetchFinished: false, otherFetchFinished: false))
        XCTAssertFalse(HLBarterScreenViewController.canPublishLiveBarter(
            ownerFetchFinished: true, otherFetchFinished: false))
        XCTAssertFalse(HLBarterScreenViewController.canPublishLiveBarter(
            ownerFetchFinished: false, otherFetchFinished: true))
        XCTAssertTrue(HLBarterScreenViewController.canPublishLiveBarter(
            ownerFetchFinished: true, otherFetchFinished: true))
    }

    func testProductIdsForLivePublishFallsBackWhenFetchFailed() {
        let local = ["local-a"]
        let fallback = ["trade-a", "trade-b", ""]
        let ids = HLBarterScreenViewController.productIdsForLivePublish(
            fetchSucceeded: false,
            localProductIds: local,
            fallbackTradeIds: fallback
        )
        XCTAssertEqual(ids, ["trade-a", "trade-b"])
    }

    func testProductIdsForLivePublishUsesLocalWhenFetchSucceeded() {
        let local = ["local-a", "local-b"]
        let fallback = ["trade-a"]
        let ids = HLBarterScreenViewController.productIdsForLivePublish(
            fetchSucceeded: true,
            localProductIds: local,
            fallbackTradeIds: fallback
        )
        XCTAssertEqual(ids, ["local-a", "local-b"])
    }

    func testExpiredTokenAlertOnlyForMissingUserOnSuccess() {
        XCTAssertTrue(HLProfileViewController.shouldPresentExpiredTokenAlert(
            httpOk: true, hasUserObject: false))
        XCTAssertFalse(HLProfileViewController.shouldPresentExpiredTokenAlert(
            httpOk: true, hasUserObject: true))
        XCTAssertFalse(HLProfileViewController.shouldPresentExpiredTokenAlert(
            httpOk: false, hasUserObject: false))
        XCTAssertFalse(HLProfileViewController.shouldPresentExpiredTokenAlert(
            httpOk: false, hasUserObject: true))
    }

    func testAddToTradeNextStepPrefersExistingRoomOverBlankButtonTitle() {
        // Options sheet calls addToTradeAction(UIButton()) with no title — must still
        // open the existing room when already trading instead of posting a duplicate.
        let openExisting = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: true,
            alreadyTradingWithOwner: true,
            pendingInboundOffer: false,
            numProducts: 2,
            roomsFull: false
        )
        if case .openExistingTrade = openExisting {} else {
            XCTFail("expected openExistingTrade when already trading")
        }

        let confirm = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: true,
            alreadyTradingWithOwner: false,
            pendingInboundOffer: false,
            numProducts: 2,
            roomsFull: false
        )
        if case .alertConfirmNewTrade = confirm {} else {
            XCTFail("expected alertConfirmNewTrade for a new trade")
        }

        let login = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: false,
            alreadyTradingWithOwner: false,
            pendingInboundOffer: false,
            numProducts: 0,
            roomsFull: false
        )
        if case .requireLogin = login {} else {
            XCTFail("expected requireLogin when logged out")
        }

        let noProducts = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: true,
            alreadyTradingWithOwner: false,
            pendingInboundOffer: false,
            numProducts: 0,
            roomsFull: false
        )
        if case .alertNoProducts = noProducts {} else {
            XCTFail("expected alertNoProducts when inventory is empty")
        }

        let roomsFull = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: true,
            alreadyTradingWithOwner: false,
            pendingInboundOffer: false,
            numProducts: 1,
            roomsFull: true
        )
        if case .alertRoomsFull = roomsFull {} else {
            XCTFail("expected alertRoomsFull when rooms are capped")
        }
    }

    func testPortraitNavigationControllerFindsNestedPortraitShell() {
        let app = AppDelegate()
        let portrait = HulaPortraitNavigationController()
        let tab = UITabBarController()
        tab.viewControllers = [UINavigationController(rootViewController: UIViewController()), portrait]
        tab.selectedIndex = 1

        XCTAssertTrue(app.portraitNavigationController(from: portrait) === portrait)
        XCTAssertTrue(app.portraitNavigationController(from: tab) === portrait)
        XCTAssertNil(app.portraitNavigationController(from: nil))
        XCTAssertNil(app.portraitNavigationController(from: UIViewController()))
    }

    func testAutocompleteKeywordsSoftParsesAndSeeds() {
        let json: [String: Any] = [
            "keywords": [
                ["keyword": "bike"],
                ["keyword": "bike"], // duplicate of seed skipped below via seed check after first
                ["keyword": "bicycle"],
                ["not_a_keyword": true],
                "string-row",
                ["keyword": NSNull()]
            ]
        ]
        let keywords = CommonUtils.autocompleteKeywords(from: json, seed: "bike")
        XCTAssertEqual(keywords, ["bike", "bicycle"])

        XCTAssertEqual(CommonUtils.autocompleteKeywords(from: nil, seed: "hat"), ["hat"])
        XCTAssertEqual(CommonUtils.autocompleteKeywords(from: ["keywords": "bad"], seed: "hat"), ["hat"])
    }

    func testProductPopulateParsesBridgedTradingCount() {
        let product = HulaProduct()
        product.populate(with: [
            "trading_count": NSNumber(value: 4)
        ] as NSDictionary)
        XCTAssertEqual(product.trading_count, 4)

        let before = product.trading_count
        product.populate(with: [
            "trading_count": true
        ] as NSDictionary)
        XCTAssertEqual(product.trading_count, before)
    }

    // MARK: - Beyond #107/#108: camera main-thread hops, album soft-parse, Facebook deep-link

    func testCustomCameraUIUpdateRunsInlineOnMainThread() {
        var ran = false
        HLCustomCameraViewController.performCameraUIUpdate {
            XCTAssertTrue(Thread.isMainThread)
            ran = true
        }
        XCTAssertTrue(ran)
    }

    func testPictureSelectUIUpdateRunsInlineOnMainThread() {
        var ran = false
        HLPictureSelectViewController.performCameraUIUpdate {
            XCTAssertTrue(Thread.isMainThread)
            ran = true
        }
        XCTAssertTrue(ran)
    }

    func testProductPictureEditUIUpdateRunsInlineOnMainThread() {
        var ran = false
        HLProductPictureEditViewController.performCameraUIUpdate {
            XCTAssertTrue(Thread.isMainThread)
            ran = true
        }
        XCTAssertTrue(ran)
    }

    func testCameraUIUpdateHopsFromBackgroundThread() {
        let expectation = self.expectation(description: "camera UI hops to main")
        DispatchQueue.global(qos: .userInitiated).async {
            HLCustomCameraViewController.performCameraUIUpdate {
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testPhotoLibraryImageMediaTypesAreImagesOnly() {
        let types = CommonUtils.photoLibraryImageMediaTypes()
        XCTAssertEqual(types, ["public.image"])
        XCTAssertFalse(types.contains("public.movie"))
    }

    func testPickedOriginalImageSoftParsesInfoDictionary() {
        XCTAssertNil(CommonUtils.pickedOriginalImage(from: [:]))
        XCTAssertNil(CommonUtils.pickedOriginalImage(from: [
            UIImagePickerControllerOriginalImage: "not-an-image"
        ]))
        let image = UIImage()
        let picked = CommonUtils.pickedOriginalImage(from: [
            UIImagePickerControllerOriginalImage: image
        ])
        XCTAssertTrue(picked === image)
    }

    func testFacebookSourceApplicationSoftReadsOptions() {
        XCTAssertNil(AppDelegate.facebookSourceApplication(from: [:]))
        let source = AppDelegate.facebookSourceApplication(from: [
            .sourceApplication: "com.facebook.Facebook"
        ])
        XCTAssertEqual(source, "com.facebook.Facebook")
    }

    // MARK: - Product form body and complete-profile title wipe (#110)

    func testProductFormPostStringDoesNotSplitOnAmpersandInTitle() {
        let body = CommonUtils.productFormPostString(
            title: "Toys & Games",
            description: "Fun=stuff",
            condition: "used",
            categoryId: "cat-1",
            imagesCSV: "a.jpg,b.jpg",
            latitude: 1.5,
            longitude: -2.5
        )

        // A naive split on '&' must still yield exactly the expected keys.
        let pairs = body.components(separatedBy: "&")
        XCTAssertEqual(pairs.count, 7)
        XCTAssertTrue(pairs[0].hasPrefix("title="))
        XCTAssertTrue(pairs[1].hasPrefix("description="))
        XCTAssertTrue(pairs[2].hasPrefix("condition="))
        XCTAssertTrue(pairs[3].hasPrefix("category_id="))
        XCTAssertTrue(pairs[4].hasPrefix("images="))
        XCTAssertEqual(pairs[5], "lat=1.5")
        XCTAssertEqual(pairs[6], "lng=-2.5")

        // urlHostAllowed would leave the title ampersand unescaped and create a bogus field.
        XCTAssertFalse(body.contains("title=Toys "))
        XCTAssertTrue(body.contains("%26"))
    }

    func testResolvedProductFieldsKeepsExistingTitleWhenFieldBlank() {
        let resolved = HLCompleteProductProfileViewController.resolvedProductFields(
            titleField: "",
            descriptionField: "Still a great item",
            existingTitle: "Untitled product",
            existingDescription: ""
        )
        XCTAssertEqual(resolved.title, "Untitled product")
        XCTAssertEqual(resolved.description, "Still a great item")
    }

    func testResolvedProductFieldsUsesTypedTitle() {
        let resolved = HLCompleteProductProfileViewController.resolvedProductFields(
            titleField: "  Bike  ",
            descriptionField: "  lightly used  ",
            existingTitle: "Untitled product",
            existingDescription: "old"
        )
        XCTAssertEqual(resolved.title, "Bike")
        XCTAssertEqual(resolved.description, "lightly used")
    }

    func testResolvedProductFieldsFallsBackToUntitledWhenNoTitleAnywhere() {
        let resolved = HLCompleteProductProfileViewController.resolvedProductFields(
            titleField: nil,
            descriptionField: "desc",
            existingTitle: nil,
            existingDescription: nil
        )
        XCTAssertEqual(resolved.title, NSLocalizedString("Untitled product", comment: ""))
        XCTAssertEqual(resolved.description, "desc")
    }

    // MARK: - Trade chat segue configuration (#110)

    func testChatConfigurationSetsTradeIdWhenChatMissing() {
        let config = HLSwappViewController.chatConfiguration(from: [
            "_id": "trade-abc"
        ] as NSDictionary)
        XCTAssertEqual(config.tradeId, "trade-abc")
        XCTAssertEqual(config.chat.count, 0)
    }

    func testChatConfigurationSetsTradeIdWhenChatNullTyped() {
        let config = HLSwappViewController.chatConfiguration(from: [
            "_id": "trade-xyz",
            "chat": NSNull()
        ] as NSDictionary)
        XCTAssertEqual(config.tradeId, "trade-xyz")
        XCTAssertEqual(config.chat.count, 0)
    }

    func testChatConfigurationPreservesExistingMessages() {
        let message: NSDictionary = ["user_id": "u1", "message": "hi", "date": "2026-01-01T00:00:00.000Z"]
        let config = HLSwappViewController.chatConfiguration(from: [
            "_id": "trade-1",
            "chat": [message]
        ] as NSDictionary)
        XCTAssertEqual(config.tradeId, "trade-1")
        XCTAssertEqual(config.chat.count, 1)
        XCTAssertEqual(config.chat[0].object(forKey: "message") as? String, "hi")
    }

    // MARK: - Soft network JSON and chat/feedback guards (beyond #109/#110)

    func testJsonObjectParsesValidPayload() {
        let data = "{\"ok\":true,\"n\":2}".data(using: .utf8)!
        let json = HLDataManager.jsonObject(from: data) as? [String: Any]
        XCTAssertEqual(json?["ok"] as? Bool, true)
        XCTAssertEqual(json?["n"] as? Int, 2)
    }

    func testJsonObjectRejectsHTMLAndEmptyBodies() {
        let html = "<html>gateway timeout</html>".data(using: .utf8)!
        XCTAssertNil(HLDataManager.jsonObject(from: html))
        XCTAssertNil(HLDataManager.jsonObject(from: Data()))
        let truncated = "{not-json".data(using: .utf8)!
        XCTAssertNil(HLDataManager.jsonObject(from: truncated))
    }

    func testChatRequestURLRejectsBlankTradeId() {
        XCTAssertNil(ChatViewController.chatRequestURL(apiBase: "https://hula.trading/api/", tradeId: ""))
        XCTAssertNil(ChatViewController.chatRequestURL(apiBase: "https://hula.trading/api/", tradeId: "   "))
        XCTAssertEqual(
            ChatViewController.chatRequestURL(apiBase: "https://hula.trading/api/", tradeId: " trade-1 "),
            "https://hula.trading/api/trades/trade-1/chat"
        )
    }

    func testFeedbackTradeRateLabelAcceptsBridgedIntegerScores() {
        // Whole-number JSON bridges as Int/NSNumber; `as? Float` would yield "-" here.
        XCTAssertEqual(
            CommonUtils.feedbackTradeRateLabel(points: 9 as Int, count: 10 as Int),
            "90%"
        )
        XCTAssertEqual(
            CommonUtils.feedbackTradeRateLabel(points: NSNumber(value: 3), count: NSNumber(value: 4)),
            "75%"
        )
        XCTAssertEqual(CommonUtils.feedbackTradeRateLabel(points: 1, count: 0), "-")
        XCTAssertEqual(CommonUtils.feedbackTradeRateLabel(points: nil, count: 2), "-")
        XCTAssertEqual(CommonUtils.feedbackTradeRateLabel(points: true, count: 1), "-")
    }

    func testDeliverUserProductsOnMainRunsInlineOnMainThread() {
        var delivered: [HulaProduct]?
        let product = HulaProduct(id: "p1", name: "Lamp", image: "")
        HLBarterScreenViewController.deliverUserProductsOnMain([product]) { products in
            delivered = products
        }
        XCTAssertEqual(delivered?.count, 1)
        XCTAssertEqual(delivered?.first?.productId, "p1")
    }

    func testDeliverUserProductsOnMainHopsFromBackgroundThread() {
        let expectation = self.expectation(description: "inventory delivered on main")
        DispatchQueue.global(qos: .userInitiated).async {
            HLBarterScreenViewController.deliverUserProductsOnMain([]) { _ in
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    // MARK: - Beyond #111/#112: cash sync, reputation, soft unread, session strings

    func testTradeOfferChangedDetectsEqualOffsetCashIncrease() {
        let current = HulaTrade()
        current.owner_products = ["p1"]
        current.other_products = ["p2"]
        current.owner_money = 0
        current.other_money = 0

        let incoming = HulaTrade()
        incoming.owner_products = ["p1"]
        incoming.other_products = ["p2"]
        incoming.owner_money = 10
        incoming.other_money = 10

        // Net difference is unchanged (0), but each side moved — must detect.
        XCTAssertTrue(HLBarterScreenViewController.tradeOfferChanged(from: current, to: incoming))
    }

    func testTradeOfferChangedIgnoresIdenticalCashAndProducts() {
        let current = HulaTrade()
        current.owner_products = ["p1"]
        current.other_products = ["p2"]
        current.owner_money = 5
        current.other_money = 2

        let incoming = HulaTrade()
        incoming.owner_products = ["p1"]
        incoming.other_products = ["p2"]
        incoming.owner_money = 5
        incoming.other_money = 2

        XCTAssertFalse(HLBarterScreenViewController.tradeOfferChanged(from: current, to: incoming))
    }

    func testTradeOfferChangedDetectsSingleSideCashChange() {
        let current = HulaTrade()
        current.owner_money = 0
        current.other_money = 0

        let incoming = HulaTrade()
        incoming.owner_money = 25
        incoming.other_money = 0

        XCTAssertTrue(HLBarterScreenViewController.tradeOfferChanged(from: current, to: incoming))
    }

    func testSellerMeetsReputationAllowsAllWhenFilterIsZero() {
        XCTAssertTrue(HLSearchResultViewController.sellerMeetsReputation(nil, minimumPercent: 0))
    }

    func testSellerMeetsReputationRejectsMissingSellerWhenThresholdSet() {
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(nil, minimumPercent: 80))
    }

    func testSellerMeetsReputationUsesFeedbackRatioWithBridgedIntegers() {
        // Whole-number JSON bridges as Int/NSNumber; `as? Float` would empty results.
        let strong: NSDictionary = [
            "feedback_points": 9 as Int,
            "feedback_count": 10 as Int
        ]
        let weak: NSDictionary = [
            "feedback_points": NSNumber(value: 5),
            "feedback_count": NSNumber(value: 10)
        ]
        let floatPayload: NSDictionary = [
            "feedback_points": Float(9),
            "feedback_count": Float(10)
        ]
        XCTAssertTrue(HLSearchResultViewController.sellerMeetsReputation(strong, minimumPercent: 80))
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(weak, minimumPercent: 80))
        XCTAssertTrue(HLSearchResultViewController.sellerMeetsReputation(floatPayload, minimumPercent: 90))
    }

    func testSellerMeetsReputationRejectsZeroFeedbackCountAndBooleans() {
        let zeroCount: NSDictionary = [
            "feedback_points": Float(0),
            "feedback_count": Float(0)
        ]
        let boolNoise: NSDictionary = [
            "feedback_points": true,
            "feedback_count": 10 as Int
        ]
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(zeroCount, minimumPercent: 80))
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(boolNoise, minimumPercent: 80))
    }

    func testReputationFilterTagPreservesNinetyNinePercent() {
        let filterVC = HLFilterViewController()
        XCTAssertEqual(filterVC.getTagForRep(99), 11)
        XCTAssertEqual(filterVC.getRepForTag(11), 99)
        XCTAssertEqual(filterVC.getTagForRep(95), 10)
        XCTAssertEqual(filterVC.getRepForTag(10), 95)
    }

    func testPeerChatContextUsesOwnerUnreadWhenViewerIsOwner() {
        let trade: NSDictionary = [
            "owner_id": "me",
            "other_id": "peer",
            "owner_unread": NSNumber(value: 3),
            "other_unread": 9 as Int
        ]
        let ctx = HLSwappViewController.peerChatContext(from: trade, viewerId: "me")
        XCTAssertEqual(ctx.peerId, "peer")
        XCTAssertEqual(ctx.unread, 3)
    }

    func testPeerChatContextUsesOtherUnreadWhenViewerIsPeer() {
        let trade: NSDictionary = [
            "owner_id": "owner",
            "other_id": "me",
            "owner_unread": 2 as Int,
            "other_unread": NSNumber(value: 4.0)
        ]
        let ctx = HLSwappViewController.peerChatContext(from: trade, viewerId: "me")
        XCTAssertEqual(ctx.peerId, "owner")
        XCTAssertEqual(ctx.unread, 4)
    }

    func testPeerChatContextDefaultsMissingUnreadAndRejectsBool() {
        let missing: NSDictionary = [
            "owner_id": "me",
            "other_id": "peer"
        ]
        XCTAssertEqual(HLSwappViewController.peerChatContext(from: missing, viewerId: "me").unread, 0)

        let boolUnread: NSDictionary = [
            "owner_id": "me",
            "other_id": "peer",
            "owner_unread": true
        ]
        XCTAssertEqual(HLSwappViewController.peerChatContext(from: boolUnread, viewerId: "me").unread, 0)
    }

    func testStringFieldPicksFirstPresentAlternateKey() {
        let dict: NSDictionary = [
            "nick": "handle",
            "name": "Full Name"
        ]
        XCTAssertEqual(HLDataManager.stringField(dict, keys: ["userNick", "nick"]), "handle")
        XCTAssertEqual(HLDataManager.stringField(dict, keys: ["userName", "name"]), "Full Name")
        XCTAssertNil(HLDataManager.stringField(dict, keys: ["token", "missing"]))
        XCTAssertNil(HLDataManager.stringField(["token": 1] as NSDictionary, keys: ["token"]))
    }

    func testUpdateUserFromDictUsesAlternateStringKeysWithoutForceCast() {
        let user = HulaUser.sharedInstance
        let previousId = user.userId
        let previousNick = user.userNick
        let previousName = user.userName
        let previousEmail = user.userEmail
        let previousBio = user.userBio
        let previousPhoto = user.userPhotoURL
        let previousLocationName = user.userLocationName
        defer {
            user.userId = previousId
            user.userNick = previousNick
            user.userName = previousName
            user.userEmail = previousEmail
            user.userBio = previousBio
            user.userPhotoURL = previousPhoto
            user.userLocationName = previousLocationName
        }

        user.logout()
        HLDataManager.sharedInstance.updateUserFromDict(dict: [
            "_id": "alt-user",
            "nick": "n1",
            "name": "Ada",
            "email": "ada@example.com",
            "bio": "builder",
            "image": "https://cdn.example/ada.jpg",
            "location_name": "Atlanta"
        ] as NSDictionary)

        XCTAssertEqual(user.userId, "alt-user")
        XCTAssertEqual(user.userNick, "n1")
        XCTAssertEqual(user.userName, "Ada")
        XCTAssertEqual(user.userEmail, "ada@example.com")
        XCTAssertEqual(user.userBio, "builder")
        XCTAssertEqual(user.userPhotoURL, "https://cdn.example/ada.jpg")
        XCTAssertEqual(user.userLocationName, "Atlanta")
    }

    // MARK: - Beyond #113/#114: pending-offer gates + session location soft-parse

    func testShouldOfferStartTradeWhenIdle() {
        XCTAssertTrue(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: false,
            pendingInboundOffer: false
        ))
    }

    func testShouldNotOfferStartTradeWhenAlreadyTrading() {
        XCTAssertFalse(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: true,
            pendingInboundOffer: false
        ))
    }

    func testShouldNotOfferStartTradeWhenPendingInboundOffer() {
        // Options → "Trade with this user" must not POST a second room while Accept/Decline is showing.
        XCTAssertFalse(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: false,
            pendingInboundOffer: true
        ))
    }

    func testShouldNotOfferStartTradeWhenBothTradingAndPending() {
        XCTAssertFalse(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: true,
            pendingInboundOffer: true
        ))
    }

    func testAddToTradeNextStepIgnoresPendingInboundOffer() {
        // Product-detail Options / Trade CTA must not burn a second room while seller
        // Accept/Decline is still the active inbound offer.
        let pending = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: true,
            alreadyTradingWithOwner: false,
            pendingInboundOffer: true,
            numProducts: 2,
            roomsFull: false
        )
        if case .ignorePendingInboundOffer = pending {} else {
            XCTFail("expected ignorePendingInboundOffer when inbound offer is pending")
        }

        // Active rooms still win over pending-inbound so the existing room opens.
        let openExisting = HLProductDetailViewController.addToTradeNextStep(
            isLoggedIn: true,
            alreadyTradingWithOwner: true,
            pendingInboundOffer: true,
            numProducts: 2,
            roomsFull: false
        )
        if case .openExistingTrade = openExisting {} else {
            XCTFail("expected openExistingTrade to prefer an active room")
        }
    }

    func testLocationFromJSONAcceptsBridgedNumberArrays() {
        let fromNSNumber = CommonUtils.location(fromJSON: [
            NSNumber(value: 33.749),
            NSNumber(value: -84.388)
        ])
        XCTAssertNotNil(fromNSNumber)
        XCTAssertEqual(fromNSNumber!.coordinate.latitude, 33.749, accuracy: 0.000001)
        XCTAssertEqual(fromNSNumber!.coordinate.longitude, -84.388, accuracy: 0.000001)

        let fromNSArray = CommonUtils.location(fromJSON: NSArray(array: [
            NSNumber(value: 40.7128),
            NSNumber(value: -74.006)
        ]))
        XCTAssertNotNil(fromNSArray)
        XCTAssertEqual(fromNSArray!.coordinate.latitude, 40.7128, accuracy: 0.000001)
        XCTAssertEqual(fromNSArray!.coordinate.longitude, -74.006, accuracy: 0.000001)
    }

    func testLocationFromJSONRejectsBoolAndMalformedPayloads() {
        XCTAssertNil(CommonUtils.location(fromJSON: nil))
        XCTAssertNil(CommonUtils.location(fromJSON: [NSNumber(value: 1.0)]))
        XCTAssertNil(CommonUtils.location(fromJSON: [true, NSNumber(value: -84.0)]))
        XCTAssertNil(CommonUtils.location(fromJSON: ["north", "west"]))
        XCTAssertNil(CommonUtils.location(fromJSON: "not coordinates"))
    }

    func testUpdateUserFromDictSoftParsesUserLocationArrays() {
        let user = HulaUser.sharedInstance
        let previousLocation = user.location
        defer { user.location = previousLocation }

        user.location = CLLocation(latitude: 0, longitude: 0)
        HLDataManager.sharedInstance.updateUserFromDict(dict: [
            "userLocation": [
                NSNumber(value: 41.3874),
                NSNumber(value: 2.1686)
            ]
        ] as NSDictionary)
        assertLocation(user.location, latitude: 41.3874, longitude: 2.1686)

        // API-shaped `location` key is accepted when userLocation is absent.
        user.location = CLLocation(latitude: 0, longitude: 0)
        HLDataManager.sharedInstance.updateUserFromDict(dict: [
            "location": NSArray(array: [
                NSNumber(value: -33.865143),
                NSNumber(value: 151.2099)
            ])
        ] as NSDictionary)
        assertLocation(user.location, latitude: -33.865143, longitude: 151.2099)

        // Malformed payloads must not wipe a good session location.
        user.location = CLLocation(latitude: 10.5, longitude: -20.25)
        HLDataManager.sharedInstance.updateUserFromDict(dict: [
            "userLocation": [true, NSNumber(value: 1.0)]
        ] as NSDictionary)
        assertLocation(user.location, latitude: 10.5, longitude: -20.25)
    }

    // MARK: - Complete-profile Done inventory index (#116)

    func testIndexOfProductFindsNonLastIncompleteProduct() {
        let a = HulaProduct(id: "a", name: "A", image: "")
        let b = HulaProduct(id: "b", name: "Untitled product", image: "")
        let c = HulaProduct(id: "c", name: "C", image: "")
        let products = [a, b, c]
        XCTAssertEqual(HLMyProductsViewController.indexOfProduct(withId: "b", in: products), 1)
        XCTAssertNotEqual(HLMyProductsViewController.indexOfProduct(withId: "b", in: products), products.count - 1)
    }

    func testIndexOfProductMissingIdReturnsNil() {
        let a = HulaProduct(id: "a", name: "A", image: "")
        XCTAssertNil(HLMyProductsViewController.indexOfProduct(withId: "missing", in: [a]))
        XCTAssertNil(HLMyProductsViewController.indexOfProduct(withId: "", in: [a]))
    }

    // MARK: - My Products payload / false session expiry (#116)

    func testProductsListPayloadAcceptsArray() {
        XCTAssertTrue(HLMyProductsViewController.isProductsListPayload([]))
        XCTAssertTrue(HLMyProductsViewController.isProductsListPayload([["_id": "1"]]))
    }

    func testProductsListPayloadRejectsErrorObject() {
        // httpGet treats any JSON as ok=true; error objects must not force re-login.
        XCTAssertFalse(HLMyProductsViewController.isProductsListPayload(["message": "Unauthorized"]))
        XCTAssertFalse(HLMyProductsViewController.isProductsListPayload(nil))
        XCTAssertFalse(HLMyProductsViewController.isProductsListPayload("bad"))
    }

    // MARK: - Home category num_products soft parse (#116)

    func testCategoryProductCountSoftParsesMissingAndNumberTypes() {
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: [:]), 0)
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: ["num_products": 12]), 12)
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: ["num_products": NSNumber(value: 7)]), 7)
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: ["num_products": 3.0]), 3)
    }

    // MARK: - Shared image URL loader (#116)

    func testResolvedImageURLFallsBackForMalformedString() {
        let malformed = "https://hula.trading/files/user/photo with spaces.jpg"
        let resolved = UIImageView.resolvedImageURL(from: malformed)
        XCTAssertNotNil(resolved)
        XCTAssertEqual(resolved?.absoluteString, HulaConstants.noProductThumb)
    }

    func testResolvedImageURLAcceptsValidAndEmpty() {
        let valid = UIImageView.resolvedImageURL(from: "https://hula.trading/files/user/ok.jpg")
        XCTAssertEqual(valid?.absoluteString, "https://hula.trading/files/user/ok.jpg")
        let empty = UIImageView.resolvedImageURL(from: "")
        XCTAssertEqual(empty?.absoluteString, HulaConstants.noProductThumb)
    }

    // MARK: - Live-barter inventory fetch-failure placeholders (#106 wiring)

    func testPlaceholderTradedProductsKeepIdsAndAreNotDeleted() {
        let placeholders = HLBarterScreenViewController.placeholderTradedProducts(from: ["p1", "", "p2"])
        XCTAssertEqual(placeholders.map { $0.productId }, ["p1", "p2"])
        for product in placeholders {
            XCTAssertNotEqual(product.productStatus, "deleted")
        }
        // generateProductArray strips only deleted/xmoney — placeholders must survive publish.
        let vc = HLBarterScreenViewController()
        XCTAssertEqual(vc.generateProductArray(from: placeholders), ["p1", "p2"])
    }

    func testProductIdsForLivePublishFallbackSurvivesEmptyLocalArrays() {
        // Failed inventory leaves local arrays empty; Accept/live_barter must keep trade IDs.
        let ids = HLBarterScreenViewController.productIdsForLivePublish(
            fetchSucceeded: false,
            localProductIds: [],
            fallbackTradeIds: ["keep-a", "keep-b"]
        )
        XCTAssertEqual(ids, ["keep-a", "keep-b"])
        XCTAssertFalse(ids.isEmpty)
    }

    // MARK: - Upload slot / picture-edit position soft parse

    func testUploadSlotIndexAcceptsInRangePositions() {
        XCTAssertEqual(HLMyProductsViewController.uploadSlotIndex(from: "0"), 0)
        XCTAssertEqual(HLMyProductsViewController.uploadSlotIndex(from: "3"), 3)
    }

    func testUploadSlotIndexRejectsBlankNonNumericAndOutOfRange() {
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: nil))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: ""))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: "x"))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: "4"))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: "-1"))
    }

    func testUploadedImagePositionAcceptsOneBasedSlots() {
        XCTAssertEqual(HLProductPictureEditViewController.uploadedImagePosition(from: "1"), 1)
        XCTAssertEqual(HLProductPictureEditViewController.uploadedImagePosition(from: "4"), 4)
        XCTAssertNil(HLProductPictureEditViewController.uploadedImagePosition(from: "0"))
        XCTAssertNil(HLProductPictureEditViewController.uploadedImagePosition(from: "bad"))
        XCTAssertNil(HLProductPictureEditViewController.uploadedImagePosition(from: nil))
    }

    // MARK: - Swapp remaining-time soft parse

    func testRemainingResponseHoursLabelRejectsMissingOrMalformed() {
        XCTAssertNil(HLSwappViewController.remainingResponseHoursLabel(lastUpdate: nil))
        XCTAssertNil(HLSwappViewController.remainingResponseHoursLabel(lastUpdate: ""))
        XCTAssertNil(HLSwappViewController.remainingResponseHoursLabel(lastUpdate: NSNumber(value: 1)))
        XCTAssertNil(HLSwappViewController.remainingResponseHoursLabel(lastUpdate: "not-a-date"))
    }

    func testRemainingResponseHoursLabelReturnsNonNegativeHours() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let lastUpdate = now.addingTimeInterval(-2 * 60 * 60).iso8601
        let label = HLSwappViewController.remainingResponseHoursLabel(
            lastUpdate: lastUpdate,
            now: now,
            courtesyHours: 72
        )
        XCTAssertNotNil(label)
        XCTAssertFalse(label?.hasPrefix("-") ?? true)
        XCTAssertNotEqual(label, "")

        let expired = HLSwappViewController.remainingResponseHoursLabel(
            lastUpdate: now.addingTimeInterval(-100 * 60 * 60).iso8601,
            now: now,
            courtesyHours: 72
        )
        XCTAssertEqual(expired, "0")
    }
}
