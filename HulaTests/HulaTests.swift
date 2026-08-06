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
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Live barter equal-offset cash sync

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

    // MARK: - Search reputation filter

    func testSellerMeetsReputationAllowsAllWhenFilterIsZero() {
        XCTAssertTrue(HLSearchResultViewController.sellerMeetsReputation(nil, minimumPercent: 0))
    }

    func testSellerMeetsReputationRejectsMissingSellerWhenThresholdSet() {
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(nil, minimumPercent: 80))
    }

    func testSellerMeetsReputationUsesFeedbackRatio() {
        let strong: NSDictionary = [
            "feedback_points": Float(9),
            "feedback_count": Float(10)
        ]
        let weak: NSDictionary = [
            "feedback_points": Float(5),
            "feedback_count": Float(10)
        ]
        XCTAssertTrue(HLSearchResultViewController.sellerMeetsReputation(strong, minimumPercent: 80))
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(weak, minimumPercent: 80))
    }

    func testSellerMeetsReputationRejectsZeroFeedbackCount() {
        let user: NSDictionary = [
            "feedback_points": Float(0),
            "feedback_count": Float(0)
        ]
        XCTAssertFalse(HLSearchResultViewController.sellerMeetsReputation(user, minimumPercent: 80))
    }

    func testReputationFilterTagPreservesNinetyNinePercent() {
        let filterVC = HLFilterViewController()
        XCTAssertEqual(filterVC.getTagForRep(99), 11)
        XCTAssertEqual(filterVC.getRepForTag(11), 99)
    }
}
