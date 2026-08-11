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
    
    /// Dragging an `xmoney` chip out of a trade tray must zero the matching cash field.
    func testMoneyAfterRemovingCashChipClearsMatchingSide() {
        // Trade owner removes cash from their own tray → owner_money clears
        let ownerMine = HLBarterScreenViewController.moneyAfterRemovingCashChip(
            productId: "xmoney",
            trayIsMySide: true,
            amITradeOwner: true,
            ownerMoney: 25,
            otherMoney: 10
        )
        XCTAssertEqual(ownerMine.ownerMoney, 0)
        XCTAssertEqual(ownerMine.otherMoney, 10)

        // Trade owner removes cash from the peer tray → other_money clears
        let ownerPeer = HLBarterScreenViewController.moneyAfterRemovingCashChip(
            productId: "xmoney",
            trayIsMySide: false,
            amITradeOwner: true,
            ownerMoney: 25,
            otherMoney: 10
        )
        XCTAssertEqual(ownerPeer.ownerMoney, 25)
        XCTAssertEqual(ownerPeer.otherMoney, 0)

        // Non-owner removes cash from their tray (mapped to other_money)
        let otherMine = HLBarterScreenViewController.moneyAfterRemovingCashChip(
            productId: "xmoney",
            trayIsMySide: true,
            amITradeOwner: false,
            ownerMoney: 25,
            otherMoney: 10
        )
        XCTAssertEqual(otherMine.ownerMoney, 25)
        XCTAssertEqual(otherMine.otherMoney, 0)

        // Non-owner removes cash from peer tray (mapped to owner_money)
        let otherPeer = HLBarterScreenViewController.moneyAfterRemovingCashChip(
            productId: "xmoney",
            trayIsMySide: false,
            amITradeOwner: false,
            ownerMoney: 25,
            otherMoney: 10
        )
        XCTAssertEqual(otherPeer.ownerMoney, 0)
        XCTAssertEqual(otherPeer.otherMoney, 10)
    }

    /// Removing a normal product must not touch cash fields.
    func testMoneyAfterRemovingCashChipIgnoresNormalProducts() {
        let result = HLBarterScreenViewController.moneyAfterRemovingCashChip(
            productId: "abc123",
            trayIsMySide: true,
            amITradeOwner: true,
            ownerMoney: 40,
            otherMoney: 5
        )
        XCTAssertEqual(result.ownerMoney, 40)
        XCTAssertEqual(result.otherMoney, 5)

        let nilId = HLBarterScreenViewController.moneyAfterRemovingCashChip(
            productId: nil,
            trayIsMySide: true,
            amITradeOwner: true,
            ownerMoney: 40,
            otherMoney: 5
        )
        XCTAssertEqual(nilId.ownerMoney, 40)
        XCTAssertEqual(nilId.otherMoney, 5)
    }
}
