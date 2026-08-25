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

    func pendingOfferTrade(id: String, owner: String, other: String, status: String, agreed: Bool) -> [String: Any] {
        return [
            "_id": id,
            "owner_id": owner,
            "other_id": other,
            "status": status,
            "other_agree": agreed
        ]
    }

    func testClosedOfferIsNotTreatedAsLiveIncomingOffer() {
        let me = "user-bob"
        let alice = "user-alice"
        let closed = pendingOfferTrade(id: "trade-old", owner: alice, other: me, status: HulaConstants.cancel_status, agreed: false)

        XCTAssertFalse(PendingOfferPolicy.isPendingIncomingOffer(closed, fromUser: alice, currentUserId: me))
        XCTAssertFalse(PendingOfferPolicy.isOffered(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [closed as NSDictionary]))
        XCTAssertEqual(PendingOfferPolicy.tradeId(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [closed as NSDictionary]), "")
        XCTAssertFalse(PendingOfferPolicy.shouldRunOfferAction(tradeId: ""))
    }

    func testPendingIncomingOfferIsFoundAndActionable() {
        let me = "user-bob"
        let alice = "user-alice"
        let pending = pendingOfferTrade(id: "trade-new", owner: alice, other: me, status: HulaConstants.pending_status, agreed: false)

        XCTAssertTrue(PendingOfferPolicy.isPendingIncomingOffer(pending, fromUser: alice, currentUserId: me))
        XCTAssertTrue(PendingOfferPolicy.isOffered(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [pending as NSDictionary]))
        XCTAssertEqual(PendingOfferPolicy.tradeId(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [pending as NSDictionary]), "trade-new")
        XCTAssertTrue(PendingOfferPolicy.shouldRunOfferAction(tradeId: "trade-new"))
    }

    func testEndedAndForeignOffersDoNotBlockTrading() {
        let me = "user-bob"
        let alice = "user-alice"
        let charlie = "user-charlie"
        let ended = pendingOfferTrade(id: "trade-ended", owner: alice, other: me, status: HulaConstants.end_status, agreed: false)
        let foreign = pendingOfferTrade(id: "trade-foreign", owner: alice, other: charlie, status: HulaConstants.pending_status, agreed: false)
        let sent = pendingOfferTrade(id: "trade-sent", owner: alice, other: me, status: HulaConstants.sent_status, agreed: false)

        XCTAssertFalse(PendingOfferPolicy.isOffered(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [ended as NSDictionary, foreign as NSDictionary]))
        XCTAssertEqual(PendingOfferPolicy.tradeId(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [ended as NSDictionary, foreign as NSDictionary]), "")
        XCTAssertTrue(PendingOfferPolicy.isOffered(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [sent as NSDictionary]))
        XCTAssertEqual(PendingOfferPolicy.tradeId(withUser: alice, currentUserId: me, currentTrades: [], allTrades: [sent as NSDictionary]), "trade-sent")
    }

    func testCurrentTradeIdIsPreferredOverStaleAllTrades() {
        let me = "user-bob"
        let alice = "user-alice"
        let current = pendingOfferTrade(id: "trade-live", owner: me, other: alice, status: HulaConstants.sent_status, agreed: true)
        let stale = pendingOfferTrade(id: "trade-stale", owner: alice, other: me, status: HulaConstants.cancel_status, agreed: false)

        XCTAssertEqual(PendingOfferPolicy.tradeId(withUser: alice, currentUserId: me, currentTrades: [current as NSDictionary], allTrades: [stale as NSDictionary, current as NSDictionary]), "trade-live")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
