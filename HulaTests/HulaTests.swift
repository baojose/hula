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
    
    func testParseNotificationsKeepsVisibleRowsAndCountsUnread() {
        let payload: [Any] = [
            ["status": "active", "is_read": 0, "text": "offer"],
            ["status": "deleted", "is_read": 0, "text": "gone"],
            ["status": "active", "is_read": 1, "text": "old"],
            ["text": "missing status", "is_read": 0]
        ]
        let parsed = NotificationListParser.parse(payload)
        XCTAssertEqual(parsed.items.count, 2)
        XCTAssertEqual(parsed.pendingCount, 3)
        let first = parsed.items.object(at: 0) as? [String: Any]
        XCTAssertEqual(first?["text"] as? String, "offer")
    }
    
    func testParseNotificationsEmptyAndInvalidPayload() {
        let empty = NotificationListParser.parse([])
        XCTAssertEqual(empty.items.count, 0)
        XCTAssertEqual(empty.pendingCount, 0)

        let invalid = NotificationListParser.parse(["ok": 1])
        XCTAssertEqual(invalid.items.count, 0)
        XCTAssertEqual(invalid.pendingCount, 0)

        let missing = NotificationListParser.parse(nil)
        XCTAssertEqual(missing.items.count, 0)
        XCTAssertEqual(missing.pendingCount, 0)
    }
    
    func testNotificationAtRejectsOutOfBounds() {
        let items: NSArray = [
            ["_id": "a", "status": "active"] as NSDictionary,
            ["_id": "b", "status": "active"] as NSDictionary
        ]
        XCTAssertEqual(NotificationListParser.notification(at: 0, in: items)?.object(forKey: "_id") as? String, "a")
        XCTAssertEqual(NotificationListParser.notification(at: 1, in: items)?.object(forKey: "_id") as? String, "b")
        XCTAssertNil(NotificationListParser.notification(at: 2, in: items))
        XCTAssertNil(NotificationListParser.notification(at: -1, in: items))
        XCTAssertNil(NotificationListParser.notification(at: 0, in: NSArray()))
    }
}
