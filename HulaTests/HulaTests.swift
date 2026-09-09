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

    func trade(_ id: String, status: String = "pending") -> NSDictionary {
        return ["_id": id, "status": status]
    }

    /// Tapping Trade Room #3 while getTrades drops that room used to index
    /// `arrTrades[2]` after the 0.2s animation delay and trap.
    func testDashboardTapDoesNotUseStaleIndexAfterListShrinks() {
        let before = [trade("t0"), trade("t1"), trade("t2")]
        XCTAssertNotNil(DashboardTradeSelection.trade(at: 2, in: before))
        XCTAssertEqual(DashboardTradeSelection.tradeId(from: before[2]), "t2")

        let after = [trade("t0"), trade("t1")]
        XCTAssertNil(DashboardTradeSelection.resolveAfterRefresh(tappedTradeId: "t2", trades: after))
        XCTAssertNil(DashboardTradeSelection.trade(at: 2, in: after))
    }

    /// A new trade inserted at row 0 used to make the delayed handler open
    /// the neighbor room (Accept/Close Deal on the wrong negotiation).
    func testDashboardTapFollowsTradeIdWhenListReorders() {
        let after = [trade("new"), trade("t0"), trade("t1")]
        guard let resolved = DashboardTradeSelection.resolveAfterRefresh(tappedTradeId: "t1", trades: after) else {
            XCTFail("expected t1 to still be in the refreshed lobby")
            return
        }
        XCTAssertEqual(resolved.index, 2)
        XCTAssertEqual(DashboardTradeSelection.tradeId(from: resolved.trade), "t1")
    }

    func testDashboardTapAbortsWhenTradeLeavesTheList() {
        XCTAssertNil(DashboardTradeSelection.resolveAfterRefresh(tappedTradeId: "gone", trades: [trade("t0")]))
        XCTAssertNil(DashboardTradeSelection.resolveAfterRefresh(tappedTradeId: "", trades: [trade("t0")]))
        XCTAssertNil(DashboardTradeSelection.resolveAfterRefresh(tappedTradeId: nil, trades: [trade("t0")]))
    }

    func testResolvedTradePrefersSnapshotIdOverStaleIndex() {
        let snapshot = trade("t1")
        let trades = [trade("t0"), trade("t1"), trade("t2")]
        guard let resolved = DashboardTradeSelection.resolvedTrade(currentTrade: snapshot, currentIndex: 0, trades: trades) else {
            XCTFail("expected snapshot id t1")
            return
        }
        XCTAssertEqual(DashboardTradeSelection.tradeId(from: resolved), "t1")
    }

    func testResolvedTradeKeepsSnapshotIfTradeLeftPublishedList() {
        let snapshot = trade("opened")
        guard let resolved = DashboardTradeSelection.resolvedTrade(currentTrade: snapshot, currentIndex: 9, trades: [trade("t0")]) else {
            XCTFail("expected to keep the opened snapshot")
            return
        }
        XCTAssertEqual(DashboardTradeSelection.tradeId(from: resolved), "opened")
    }

    func testResolvedTradeBoundsChecksIndexWhenNoSnapshot() {
        XCTAssertNil(DashboardTradeSelection.resolvedTrade(currentTrade: nil, currentIndex: 2, trades: [trade("t0")]))
        guard let resolved = DashboardTradeSelection.resolvedTrade(currentTrade: nil, currentIndex: 0, trades: [trade("t0")]) else {
            XCTFail("expected index 0")
            return
        }
        XCTAssertEqual(DashboardTradeSelection.tradeId(from: resolved), "t0")
    }
}
