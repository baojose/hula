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

    // MARK: - Notifications loading flag (infinite retry loop)

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
            ["_id": "3", "status": "active", "is_read": 1]
        ]
        let payload = HLDataManager.notificationsPayload(from: json)
        XCTAssertEqual(payload.items.count, 2)
        XCTAssertEqual(payload.pending, 1)
    }

    func testNotificationsPayloadHandlesNilAndMalformed() {
        let empty = HLDataManager.notificationsPayload(from: nil)
        XCTAssertEqual(empty.items.count, 0)
        XCTAssertEqual(empty.pending, 0)

        let bad = HLDataManager.notificationsPayload(from: ["not": "an array"])
        XCTAssertEqual(bad.items.count, 0)
        XCTAssertEqual(bad.pending, 0)
    }

    // MARK: - Barter live_barter product wipe gate

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

    // MARK: - Profile expired-token presentation policy

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
}
