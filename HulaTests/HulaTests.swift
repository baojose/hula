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

    func testPartitionTradesKeepsActiveRoomsInCurrent() {
        let me = "user-me"
        let trades: [NSDictionary] = [
            ["_id": "t1", "status": HulaConstants.sent_status, "owner_id": me, "other_id": "u2", "turn_user_id": "u2"],
            ["_id": "t2", "status": HulaConstants.pending_status, "owner_id": "u3", "other_id": me, "turn_user_id": me, "other_agree": true],
            ["_id": "t3", "status": HulaConstants.end_status, "owner_id": me, "other_id": "u4"],
            ["_id": "t4", "status": HulaConstants.review_status, "owner_id": me, "other_id": "u5"],
            ["_id": "t5", "status": HulaConstants.pending_status, "owner_id": me, "other_id": "u6", "turn_user_id": "u6"]
        ]

        let partitioned = HLDataManager.partitionTrades(trades, userId: me)

        XCTAssertEqual(partitioned.all.count, 5)
        XCTAssertEqual(partitioned.current.count, 2)
        XCTAssertEqual(partitioned.past.count, 2)

        let currentIds = partitioned.current.flatMap { $0.object(forKey: "_id") as? String }
        XCTAssertEqual(Set(currentIds), Set(["t1", "t2"]))

        let pastIds = partitioned.past.flatMap { $0.object(forKey: "_id") as? String }
        XCTAssertEqual(Set(pastIds), Set(["t3", "t4"]))
    }

    func testPartitionTradesSkipsMalformedIdsWithoutCrashing() {
        let me = "user-me"
        let trades: [NSDictionary] = [
            ["_id": "ok", "status": HulaConstants.sent_status, "owner_id": me, "other_id": "u2"],
            ["_id": "missing-owner", "status": HulaConstants.sent_status, "other_id": "u2"],
            ["_id": "pending-no-turn", "status": HulaConstants.pending_status, "owner_id": me, "other_id": "u3"]
        ]

        let partitioned = HLDataManager.partitionTrades(trades, userId: me)

        XCTAssertEqual(partitioned.all.count, 3)
        XCTAssertEqual(partitioned.current.count, 1)
        XCTAssertEqual(partitioned.current.first?.object(forKey: "_id") as? String, "ok")
    }

    func testMyRoomsFullUsesPublishedCurrentCount() {
        let dm = HLDataManager.sharedInstance
        let previousMax = HulaUser.sharedInstance.maxTrades
        let previousCurrent = dm.arrCurrentTrades
        let previousAll = dm.arrTrades
        let previousPast = dm.arrPastTrades
        defer {
            HulaUser.sharedInstance.maxTrades = previousMax
            dm.arrCurrentTrades = previousCurrent
            dm.arrTrades = previousAll
            dm.arrPastTrades = previousPast
        }

        HulaUser.sharedInstance.maxTrades = 2
        let me = "user-me"
        let trades: [NSDictionary] = [
            ["_id": "t1", "status": HulaConstants.sent_status, "owner_id": me, "other_id": "u2"],
            ["_id": "t2", "status": HulaConstants.sent_status, "owner_id": me, "other_id": "u3"],
            ["_id": "t3", "status": HulaConstants.end_status, "owner_id": me, "other_id": "u4"]
        ]
        let partitioned = HLDataManager.partitionTrades(trades, userId: me)

        // Simulate the pre-fix race window: shared current list must not be
        // cleared before the replacement is ready.
        XCTAssertEqual(partitioned.current.count, 2)

        dm.arrTrades = partitioned.all
        dm.arrCurrentTrades = partitioned.current
        dm.arrPastTrades = partitioned.past

        XCTAssertTrue(dm.myRoomsFull())

        dm.arrCurrentTrades = Array(partitioned.current.prefix(1))
        XCTAssertFalse(dm.myRoomsFull())
    }

}
