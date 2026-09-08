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

    func product(_ id: String) -> HulaProduct {
        return HulaProduct(id: id, name: "Item \(id)", image: "")
    }

    func ids(of products: [HulaProduct]) -> [String] {
        return products.map { $0.productId ?? "" }
    }

    /// Opening a trade room with 3+ listings used to trap when the traded item was first
    /// in inventory: `remove(at: 0)` then the `0...count-1` loop still indexed the old last slot.
    func testBarterInventoryRemoveDoesNotTrapWhenTradedItemIsFirstOfMany() {
        let inventory = [product("p0"), product("p1"), product("p2"), product("p3")]
        let remaining = BarterInventoryPolicy.removingTraded(from: inventory, tradedIds: ["p0"])
        XCTAssertEqual(ids(of: remaining), ["p1", "p2", "p3"])
    }

    func testBarterInventoryRemovesMultipleTradedIds() {
        let inventory = [product("a"), product("b"), product("c"), product("d")]
        let remaining = BarterInventoryPolicy.removingTraded(from: inventory, tradedIds: ["a", "c"])
        XCTAssertEqual(ids(of: remaining), ["b", "d"])
    }

    func testBarterInventoryUnmatchedIdsLeaveInventoryIntact() {
        let inventory = [product("a"), product("b")]
        let remaining = BarterInventoryPolicy.removingTraded(from: inventory, tradedIds: ["missing"])
        XCTAssertEqual(ids(of: remaining), ["a", "b"])
    }

    func testBarterInventoryEmptyAndEmptyTradeList() {
        XCTAssertEqual(ids(of: BarterInventoryPolicy.removingTraded(from: [], tradedIds: ["a"])), [])
        let inventory = [product("a")]
        XCTAssertEqual(ids(of: BarterInventoryPolicy.removingTraded(from: inventory, tradedIds: [])), ["a"])
    }
}
