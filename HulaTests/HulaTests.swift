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
    
    func testFloatFromJSONAcceptsWholeNumberIntegers() {
        let intValue: Any = NSNumber(value: 50)
        XCTAssertEqual(CommonUtils.floatFromJSON(intValue), 50)
        XCTAssertEqual(CommonUtils.floatFromJSON(50 as Int), 50)
    }

    func testFloatFromJSONAcceptsFloatingPointNumbers() {
        XCTAssertEqual(CommonUtils.floatFromJSON(NSNumber(value: 12.5)), 12.5)
        XCTAssertEqual(CommonUtils.floatFromJSON(7.25 as Double), 7.25)
        XCTAssertEqual(CommonUtils.floatFromJSON(Float(3.5)), 3.5)
    }

    func testFloatFromJSONRejectsBooleans() {
        XCTAssertNil(CommonUtils.floatFromJSON(true))
        XCTAssertNil(CommonUtils.floatFromJSON(false))
        XCTAssertNil(CommonUtils.floatFromJSON(NSNumber(value: true)))
    }

    func testTradeLoadFromParsesIntegerCashAmounts() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "owner_money": 50,
            "other_money": 25
        ] as NSDictionary)

        XCTAssertEqual(trade.owner_money, 50)
        XCTAssertEqual(trade.other_money, 25)
    }

    func testTradeLoadFromParsesFloatingCashAmounts() {
        let trade = HulaTrade()
        trade.loadFrom(dict: [
            "owner_money": NSNumber(value: 12.5),
            "other_money": NSNumber(value: 0.0)
        ] as NSDictionary)

        XCTAssertEqual(trade.owner_money, 12.5)
        XCTAssertEqual(trade.other_money, 0)
    }

    func testTradeLoadFromIgnoresBooleanCashAmounts() {
        let trade = HulaTrade()
        trade.owner_money = 9
        trade.other_money = 8
        trade.loadFrom(dict: [
            "owner_money": true,
            "other_money": false
        ] as NSDictionary)

        XCTAssertEqual(trade.owner_money, 9)
        XCTAssertEqual(trade.other_money, 8)
    }

    func testFormEncodedValueEncodesPlusAmpersandAndEquals() {
        let email = CommonUtils.formEncodedValue("user+tag@gmail.com")
        XCTAssertEqual(email, "user%2Btag@gmail.com")
        XCTAssertFalse(email.contains("+"))

        let password = CommonUtils.formEncodedValue("a&b=c+d")
        XCTAssertEqual(password, "a%26b%3Dc%2Bd")
        XCTAssertFalse(password.contains("&"))
        XCTAssertFalse(password.contains("="))
        XCTAssertFalse(password.contains("+"))
    }

    func testFormEncodedValueLeavesDelimitersToCaller() {
        let body = "email=" + CommonUtils.formEncodedValue("a+b@c.com")
            + "&pass=" + CommonUtils.formEncodedValue("x&y=z")
        XCTAssertTrue(body.hasPrefix("email="))
        XCTAssertTrue(body.contains("&pass="))
        XCTAssertTrue(body.contains("email=a%2Bb@c.com"))
        XCTAssertTrue(body.contains("pass=x%26y%3Dz"))
        XCTAssertFalse(body.contains("email=a+b@c.com"))
        XCTAssertFalse(body.contains("&pass=x&y=z"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure here.
        }
    }
    
}
