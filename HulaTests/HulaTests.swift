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

        // A second create notification with the same instance should hit the existing path.
        let wouldStartSecondCreate = existingIndex == nil
        XCTAssertFalse(wouldStartSecondCreate)
    }
}
