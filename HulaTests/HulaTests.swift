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

    func testTradeLoadFromUsesOnlyLatestBidDiffAndDefaultsMissingFlags() {
        let trade = HulaTrade()
        let payload: NSDictionary = [
            "_id": "trade-1",
            "product_id": "product-1",
            "owner_id": "owner-1",
            "other_id": "other-1",
            "other_agree": true,
            "other_ready": true,
            "owner_ready": false,
            "date": "2017-05-28T12:00:00.000Z",
            "last_update": "2017-05-29T13:30:00.000Z",
            "owner_products": ["owner-old", "owner-new"],
            "other_products": ["other-new"],
            "owner_money": Float(12.5),
            "other_money": Float(7.0),
            "next_bid": "other-1",
            "status": "offer_sent",
            "turn_user_id": "owner-1",
            "bids": [
                [
                    "owner_diff": ["stale-owner"],
                    "other_diff": ["stale-other"]
                ],
                [
                    "owner_diff": ["owner-added"],
                    "other_diff": ["other-removed"]
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
        XCTAssertEqual(trade.owner_products, ["owner-old", "owner-new"])
        XCTAssertEqual(trade.other_products, ["other-new"])
        XCTAssertEqual(trade.next_bid, "other-1")
        XCTAssertEqual(trade.status, "offer_sent")
        XCTAssertEqual(trade.turn_user_id, "owner-1")
        XCTAssertEqual(trade.num_bids, 2)
        XCTAssertEqual(trade.last_bid_diff, ["owner-added", "other-removed"])
        XCTAssertEqual(trade.owner_unread, 0)
        XCTAssertEqual(trade.other_unread, 0)
        XCTAssertFalse(trade.owner_accepted)
        XCTAssertFalse(trade.other_accepted)
    }

    func testTradePostStringSerializesTradePayloadFields() {
        let trade = HulaTrade()
        trade.product_id = "product-1"
        trade.owner_id = "owner-1"
        trade.other_id = "other-1"
        trade.date = Date(timeIntervalSince1970: 0)
        trade.owner_products = ["owner-a", "owner-b"]
        trade.other_products = ["other-a"]
        trade.next_bid = "other-1"
        trade.status = "pending"
        trade.turn_user_id = "owner-1"
        trade.owner_money = 10.5
        trade.other_money = 4.0

        let postString = trade.get_post_string()

        XCTAssertTrue(postString.contains("product_id=product-1"))
        XCTAssertTrue(postString.contains("owner_id=owner-1"))
        XCTAssertTrue(postString.contains("other_id=other-1"))
        XCTAssertTrue(postString.contains("date=1970-01-01T00:00:00.000Z"))
        XCTAssertTrue(postString.contains("owner_products=owner-aowner-b"))
        XCTAssertTrue(postString.contains("other_products=other-a"))
        XCTAssertTrue(postString.contains("next_bid=other-1"))
        XCTAssertTrue(postString.contains("status=pending"))
        XCTAssertTrue(postString.contains("turn_user_id=owner-1"))
        XCTAssertTrue(postString.contains("owner_money=10.5"))
        XCTAssertTrue(postString.contains("other_money=4.0"))
    }

    func testProductPopulateFiltersBlankImagesAndMapsLocation() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "_id": "product-1",
            "title": "Vintage lamp",
            "description": "Works well",
            "condition": "used",
            "category_name": "Home",
            "category_id": "cat-home",
            "image_url": "https://hula.trading/files/product/lamp.jpg",
            "status": "active",
            "owner_id": "owner-1",
            "video_requested": ["user-2": true],
            "video_url": ["user-2": "https://hula.trading/files/video/lamp.mp4"],
            "trading_count": 3,
            "images": [
                "https://hula.trading/files/product/lamp-1.jpg",
                "",
                "https://hula.trading/files/product/lamp-2.jpg"
            ],
            "location": [37.7749, -122.4194]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productId, "product-1")
        XCTAssertEqual(product.productName, "Vintage lamp")
        XCTAssertEqual(product.productDescription, "Works well")
        XCTAssertEqual(product.productCondition, "used")
        XCTAssertEqual(product.productCategory, "Home")
        XCTAssertEqual(product.productCategoryId, "cat-home")
        XCTAssertEqual(product.productImage, "https://hula.trading/files/product/lamp.jpg")
        XCTAssertEqual(product.productStatus, "active")
        XCTAssertEqual(product.productOwner, "owner-1")
        XCTAssertEqual(product.arrProductPhotoLink, [
            "https://hula.trading/files/product/lamp-1.jpg",
            "https://hula.trading/files/product/lamp-2.jpg"
        ])
        XCTAssertEqual(product.video_requested["user-2"], true)
        XCTAssertEqual(product.video_url["user-2"], "https://hula.trading/files/video/lamp.mp4")
        XCTAssertEqual(product.trading_count, 3)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.4194, accuracy: 0.0001)
    }

    func testProductPostStringUsesCurrentUserLocationForServerPayload() {
        HulaUser.sharedInstance.location = CLLocation(latitude: 40.7128, longitude: -74.0060)

        let product = HulaProduct()
        product.productName = "Road bike"
        product.productDescription = "Lightweight frame"
        product.productCondition = "used"
        product.productCategory = "Sports"
        product.productCategoryId = "cat-sports"
        product.productImage = "https://hula.trading/files/product/bike.jpg"
        product.productOwner = "owner-1"
        product.arrProductPhotoLink = [
            "https://hula.trading/files/product/bike-1.jpg",
            "https://hula.trading/files/product/bike-2.jpg"
        ]

        let postString = product.getPostString()

        XCTAssertTrue(postString.contains("title=Road bike"))
        XCTAssertTrue(postString.contains("description=Lightweight frame"))
        XCTAssertTrue(postString.contains("condition=used"))
        XCTAssertTrue(postString.contains("category_name=Sports"))
        XCTAssertTrue(postString.contains("category_id=cat-sports"))
        XCTAssertTrue(postString.contains("image_url=https://hula.trading/files/product/bike.jpg"))
        XCTAssertTrue(postString.contains("owner_id=owner-1"))
        XCTAssertTrue(postString.contains("images=https://hula.trading/files/product/bike-1.jpg,https://hula.trading/files/product/bike-2.jpg"))
        XCTAssertTrue(postString.contains("lat=40.7128"))
        XCTAssertTrue(postString.contains("lng=-74.006"))
    }

    func testUserPopulateMapsProfileFieldsAndFeedback() {
        let user = HulaUser()
        let payload: NSDictionary = [
            "_id": "user-1",
            "name": "Jamie Trader",
            "nick": "jamie",
            "bio": "Trades vintage electronics",
            "email": "jamie@example.com",
            "image": "https://hula.trading/files/user/jamie.jpg",
            "location": [CGFloat(34.0522), CGFloat(-118.2437)],
            "location_name": "Los Angeles, CA",
            "fb_token": "fb-token",
            "tw_token": "tw-token",
            "li_token": "li-token",
            "status": "active",
            "zip": "90001",
            "feedback_count": Float(4.0),
            "feedback_points": Float(3.0),
            "trades_started": Float(8.0),
            "trades_finished": Float(6.0),
            "trades_closed": Float(1.0),
            "deviceId": "device-1",
            "max_trades": 5
        ]

        user.populate(with: payload)

        XCTAssertEqual(user.userId, "user-1")
        XCTAssertEqual(user.userName, "Jamie Trader")
        XCTAssertEqual(user.userNick, "jamie")
        XCTAssertEqual(user.userBio, "Trades vintage electronics")
        XCTAssertEqual(user.userEmail, "jamie@example.com")
        XCTAssertEqual(user.userPhotoURL, "https://hula.trading/files/user/jamie.jpg")
        XCTAssertEqual(user.location.coordinate.latitude, 34.0522, accuracy: 0.0001)
        XCTAssertEqual(user.location.coordinate.longitude, -118.2437, accuracy: 0.0001)
        XCTAssertEqual(user.userLocationName, "Los Angeles, CA")
        XCTAssertEqual(user.fbToken, "fb-token")
        XCTAssertEqual(user.twToken, "tw-token")
        XCTAssertEqual(user.liToken, "li-token")
        XCTAssertEqual(user.status, "active")
        XCTAssertEqual(user.zip, "90001")
        XCTAssertEqual(user.trades_started, 8.0)
        XCTAssertEqual(user.trades_finished, 6.0)
        XCTAssertEqual(user.trades_closed, 1.0)
        XCTAssertEqual(user.deviceId, "device-1")
        XCTAssertEqual(user.maxTrades, 5)
        XCTAssertEqual(user.getFeedback(), "75%")
        XCTAssertFalse(user.isIncompleteProfile())
    }

    func testUserPostStringIncludesLocationOnlyWhenAvailable() {
        let user = HulaUser()
        user.userEmail = "jamie@example.com"
        user.userName = "Jamie Trader"
        user.userBio = "Trades vintage electronics"
        user.userNick = "jamie"
        user.userPhotoURL = "https://hula.trading/files/user/jamie.jpg"
        user.twToken = "tw-token"
        user.liToken = "li-token"
        user.fbToken = "fb-token"
        user.deviceId = "device-1"
        user.zip = "90001"
        user.maxTrades = 5

        XCTAssertFalse(user.getPostString().contains("&lat="))

        user.location = CLLocation(latitude: 34.0522, longitude: -118.2437)
        user.userLocationName = "Los Angeles, CA"
        let postString = user.getPostString()

        XCTAssertTrue(postString.contains("email=jamie@example.com"))
        XCTAssertTrue(postString.contains("name=Jamie Trader"))
        XCTAssertTrue(postString.contains("bio=Trades vintage electronics"))
        XCTAssertTrue(postString.contains("nick=jamie"))
        XCTAssertTrue(postString.contains("image=https://hula.trading/files/user/jamie.jpg"))
        XCTAssertTrue(postString.contains("twtoken=tw-token"))
        XCTAssertTrue(postString.contains("litoken=li-token"))
        XCTAssertTrue(postString.contains("fbtoken=fb-token"))
        XCTAssertTrue(postString.contains("push_device_id=device-1"))
        XCTAssertTrue(postString.contains("zip=90001"))
        XCTAssertTrue(postString.contains("max_trades=5"))
        XCTAssertTrue(postString.contains("lat=34.0522"))
        XCTAssertTrue(postString.contains("lng=-118.2437"))
        XCTAssertTrue(postString.contains("location_name=Los Angeles, CA"))
    }

    func testThumbnailUrlRewritesOnlyTheFinalPathComponent() {
        let utils = CommonUtils.sharedInstance

        XCTAssertEqual(utils.getThumbFor(url: ""), HulaConstants.noProductThumb)
        XCTAssertEqual(utils.getThumbFor(url: HulaConstants.transparentImg), HulaConstants.transparentImg)
        XCTAssertEqual(
            utils.getThumbFor(url: "https://hula.trading/files/product/lamp.jpg"),
            "https://hula.trading/files/product/tm_lamp.jpg"
        )
    }

    func testFilterMappingsReturnServerValuesForSelectedTags() {
        let filters = HLFilterViewController()

        XCTAssertEqual(filters.getDistanceForTag(1), 5)
        XCTAssertEqual(filters.getDistanceForTag(2), 10)
        XCTAssertEqual(filters.getDistanceForTag(3), 20)
        XCTAssertEqual(filters.getDistanceForTag(4), 50)
        XCTAssertEqual(filters.getDistanceForTag(5), 0)
        XCTAssertEqual(filters.getTagForDistance(5), 1)
        XCTAssertEqual(filters.getTagForDistance(10), 2)
        XCTAssertEqual(filters.getTagForDistance(20), 3)
        XCTAssertEqual(filters.getTagForDistance(50), 4)
        XCTAssertEqual(filters.getTagForDistance(0), 5)

        XCTAssertEqual(filters.getRepForTag(6), 0)
        XCTAssertEqual(filters.getRepForTag(7), 80)
        XCTAssertEqual(filters.getRepForTag(8), 85)
        XCTAssertEqual(filters.getRepForTag(9), 90)
        XCTAssertEqual(filters.getRepForTag(10), 95)
        XCTAssertEqual(filters.getRepForTag(11), 99)
        XCTAssertEqual(filters.getTagForRep(0), 6)
        XCTAssertEqual(filters.getTagForRep(80), 7)
        XCTAssertEqual(filters.getTagForRep(85), 8)
        XCTAssertEqual(filters.getTagForRep(90), 9)
        XCTAssertEqual(filters.getTagForRep(95), 10)

        XCTAssertEqual(filters.getCondForTag(12), "new")
        XCTAssertEqual(filters.getCondForTag(13), "used")
        XCTAssertEqual(filters.getCondForTag(14), "all")
        XCTAssertEqual(filters.getTagForCond("new"), 12)
        XCTAssertEqual(filters.getTagForCond("used"), 13)
        XCTAssertEqual(filters.getTagForCond("all"), 14)
    }

    private func resetSharedUser() {
        let user = HulaUser.sharedInstance
        user.logout()
        user.location = CLLocation(latitude: 0, longitude: 0)
    }

}
