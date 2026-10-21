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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testReviewStatusKeepsReceiptConfirmationDespiteReadyFlags() {
        XCTAssertEqual(
            TradeOfferButtonPolicy.finalTag(status: HulaConstants.review_status, peerReady: true),
            TradeOfferButtonPolicy.productsReceivedTag
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.finalTag(status: HulaConstants.review_status, peerReady: false),
            TradeOfferButtonPolicy.productsReceivedTag
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.submittedStatus(tag: TradeOfferButtonPolicy.productsReceivedTag),
            HulaConstants.review_status
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.submittedAccepted(tag: TradeOfferButtonPolicy.productsReceivedTag),
            "true"
        )
    }

    func testBarterReadyFlagsStillSelectAcceptOrCloseDeal() {
        XCTAssertEqual(
            TradeOfferButtonPolicy.finalTag(status: HulaConstants.sent_status, peerReady: false),
            TradeOfferButtonPolicy.justAcceptTag
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.finalTag(status: HulaConstants.pending_status, peerReady: false),
            TradeOfferButtonPolicy.justAcceptTag
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.finalTag(status: "", peerReady: true),
            TradeOfferButtonPolicy.closeDealTag
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.submittedStatus(tag: TradeOfferButtonPolicy.justAcceptTag),
            HulaConstants.sent_status
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.submittedAccepted(tag: TradeOfferButtonPolicy.justAcceptTag),
            "false"
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.submittedStatus(tag: TradeOfferButtonPolicy.closeDealTag),
            HulaConstants.review_status
        )
        XCTAssertEqual(
            TradeOfferButtonPolicy.submittedAccepted(tag: TradeOfferButtonPolicy.closeDealTag),
            "false"
        )
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
