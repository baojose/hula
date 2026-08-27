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

    func seededTrade() -> HulaTrade {
        let trade = HulaTrade()
        trade.tradeId = "trade-abc"
        trade.owner_id = "owner-1"
        trade.other_id = "other-2"
        trade.owner_products = ["prod-owner"]
        trade.other_products = ["prod-other"]
        trade.owner_money = 25
        trade.other_money = 10
        trade.owner_ready = true
        trade.other_ready = true
        trade.other_agree = true
        return trade
    }

    func testLiveBarterSparsePayloadKeepsIdentityAndProducts() {
        let current = seededTrade()
        let payload: NSDictionary = [
            "ok": 1,
            "_id": "livebarter-oid-not-the-trade"
        ]
        let merged = HLBarterScreenViewController.mergingLiveBarterPayload(payload, into: current)
        XCTAssertEqual(merged.tradeId, "trade-abc")
        XCTAssertEqual(merged.owner_id, "owner-1")
        XCTAssertEqual(merged.other_id, "other-2")
        XCTAssertEqual(merged.owner_products, ["prod-owner"])
        XCTAssertEqual(merged.other_products, ["prod-other"])
        XCTAssertEqual(merged.owner_money, 25)
        XCTAssertEqual(merged.other_money, 10)
        XCTAssertTrue(merged.owner_ready)
        XCTAssertTrue(merged.other_ready)
    }

    func testLiveBarterExplicitProductsApplyWithoutBlankingOwner() {
        let current = seededTrade()
        let payload: NSDictionary = [
            "owner_products": ["new-owner"],
            "other_products": ["new-other"],
            "owner_money": Float(5),
            "other_money": Float(0)
        ]
        let merged = HLBarterScreenViewController.mergingLiveBarterPayload(payload, into: current)
        XCTAssertEqual(merged.tradeId, "trade-abc")
        XCTAssertEqual(merged.owner_id, "owner-1")
        XCTAssertEqual(merged.owner_products, ["new-owner"])
        XCTAssertEqual(merged.other_products, ["new-other"])
        XCTAssertEqual(merged.owner_money, 5)
        XCTAssertEqual(merged.other_money, 0)
        XCTAssertTrue(merged.owner_ready)
        XCTAssertTrue(merged.other_ready)
    }

    func testLiveBarterEmptyProductArrayIsApplied() {
        let current = seededTrade()
        let payload: NSDictionary = [
            "owner_products": [] as [String],
            "other_products": ["kept-other"]
        ]
        let merged = HLBarterScreenViewController.mergingLiveBarterPayload(payload, into: current)
        XCTAssertEqual(merged.owner_products, [])
        XCTAssertEqual(merged.other_products, ["kept-other"])
        XCTAssertEqual(merged.tradeId, "trade-abc")
        XCTAssertEqual(merged.owner_id, "owner-1")
    }

    func testPastTradeCashRemapsForNonOwner() {
        let trade = seededTrade()
        // Non-owner looking at "other" tray should see owner's cash.
        XCTAssertEqual(
            HLPastTradeViewController.cashAmount(forDisplayedType: "other", trade: trade, currentUserIsOwner: false),
            25
        )
        XCTAssertEqual(
            HLPastTradeViewController.cashAmount(forDisplayedType: "owner", trade: trade, currentUserIsOwner: false),
            10
        )
        XCTAssertEqual(
            HLPastTradeViewController.cashAmount(forDisplayedType: "other", trade: trade, currentUserIsOwner: true),
            10
        )
        XCTAssertEqual(
            HLPastTradeViewController.cashAmount(forDisplayedType: "owner", trade: trade, currentUserIsOwner: true),
            25
        )
    }

    func testUserLocationEmptyArrayDoesNotCrash() {
        XCTAssertNil(HulaUser.location(fromJSON: [] as [Any]))
        XCTAssertNil(HulaUser.location(fromJSON: [37.7] as [Any]))
        XCTAssertNil(HulaUser.location(fromJSON: NSNull()))
        XCTAssertNil(HulaUser.location(fromJSON: nil))
    }

    func testUserLocationParsesNumberPair() {
        let loc = HulaUser.location(fromJSON: [37.7, -122.4] as [Any])
        XCTAssertNotNil(loc)
        XCTAssertEqual(loc!.coordinate.latitude, 37.7, accuracy: 0.0001)
        XCTAssertEqual(loc!.coordinate.longitude, -122.4, accuracy: 0.0001)

        let user = HulaUser()
        user.populate(with: [
            "_id": "u1",
            "location": [40.0, -74.0]
        ] as NSDictionary)
        XCTAssertEqual(user.location.coordinate.latitude, 40.0, accuracy: 0.0001)
        XCTAssertEqual(user.location.coordinate.longitude, -74.0, accuracy: 0.0001)

        user.populate(with: ["location": [] as [Any]] as NSDictionary)
        XCTAssertEqual(user.location.coordinate.latitude, 40.0, accuracy: 0.0001)
    }

    func testTradeRoomOptionsSnapshotIgnoresLaterCellReuse() {
        let presented = HLTradesCollectionViewCell.actionSnapshot(tradeId: "trade-B", userId: "user-B", status: "current")
        XCTAssertEqual(presented?.tradeId, "trade-B")
        XCTAssertEqual(presented?.userId, "user-B")

        // Cell reused onto another room while the action sheet is still visible.
        let reused = HLTradesCollectionViewCell.actionSnapshot(tradeId: "trade-C", userId: "user-C", status: "current")
        XCTAssertEqual(reused?.tradeId, "trade-C")
        XCTAssertEqual(presented?.tradeId, "trade-B")
        XCTAssertEqual(presented?.userId, "user-B")

        XCTAssertNil(HLTradesCollectionViewCell.actionSnapshot(tradeId: "", userId: "user-B", status: "current"))
        XCTAssertNil(HLTradesCollectionViewCell.actionSnapshot(tradeId: "trade-B", userId: "user-B", status: "past"))
    }
}
