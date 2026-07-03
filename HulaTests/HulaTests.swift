//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Hula

class HulaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func assertLocation(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.000000001, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.000000001, file: file, line: line)
    }
    
    func testProductPopulateAcceptsPreciseNumericLocationPayloads() {
        let product = HulaProduct()

        product.populate(with: [
            "location": [
                NSNumber(value: 41.387123456),
                NSNumber(value: 2.168987654)
            ]
        ])

        assertLocation(product.productLocation, latitude: 41.387123456, longitude: 2.168987654)
    }

    func testProductPopulateAcceptsBridgedNSArrayLocationPayloads() {
        let product = HulaProduct()

        product.populate(with: [
            "location": NSArray(array: [
                NSNumber(value: 12.5),
                NSNumber(value: -70.25)
            ])
        ])

        assertLocation(product.productLocation, latitude: 12.5, longitude: -70.25)
    }

    func testProductPopulatePreservesLocationForMalformedPayloads() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": [NSNumber(value: 99.0)]])
        assertLocation(product.productLocation, latitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": [true, NSNumber(value: -30.0)]])
        assertLocation(product.productLocation, latitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": "not coordinates"])
        assertLocation(product.productLocation, latitude: 10.25, longitude: -20.5)
    }

    func testUserPopulateAcceptsPreciseNumericLocationPayloads() {
        let user = HulaUser()

        user.populate(with: [
            "location": [
                NSNumber(value: -33.865143),
                NSNumber(value: 151.2099)
            ]
        ])

        assertLocation(user.location, latitude: -33.865143, longitude: 151.2099)
    }

    func testUserPopulatePreservesLocationForMalformedPayloads() {
        let user = HulaUser()
        user.location = CLLocation(latitude: 1.5, longitude: 2.5)

        user.populate(with: ["location": [] as [Any]])
        assertLocation(user.location, latitude: 1.5, longitude: 2.5)

        user.populate(with: ["location": [NSNumber(value: true), NSNumber(value: 4.0)]])
        assertLocation(user.location, latitude: 1.5, longitude: 2.5)

        user.populate(with: ["location": ["north", "west"]])
        assertLocation(user.location, latitude: 1.5, longitude: 2.5)
    }

    func testTradeLoadFromHandlesEmptyBidsWithoutStaleDiffs() {
        let trade = HulaTrade()
        trade.num_bids = 2
        trade.last_bid_diff = ["stale-owner", "stale-other"]

        trade.loadFrom(dict: ["bids": [] as [Any]])

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertTrue(trade.last_bid_diff.isEmpty)
    }

    func testTradeLoadFromClearsBidStateWhenBidsAreAbsent() {
        let trade = HulaTrade()
        trade.num_bids = 1
        trade.last_bid_diff = ["stale"]

        trade.loadFrom(dict: NSDictionary())

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertTrue(trade.last_bid_diff.isEmpty)
    }

    func testTradeLoadFromUsesLatestBidDiffs() {
        let trade = HulaTrade()

        trade.loadFrom(dict: [
            "bids": [
                [
                    "owner_diff": ["old-owner"],
                    "other_diff": ["old-other"]
                ],
                [
                    "owner_diff": ["owner-a", "owner-b"],
                    "other_diff": ["other-a"]
                ]
            ]
        ])

        XCTAssertEqual(trade.num_bids, 2)
        XCTAssertEqual(trade.last_bid_diff, ["owner-a", "owner-b", "other-a"])
    }

    func testPublicSocialCredentialPlaceholdersRemainSanitized() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedInClientId, "")
        XCTAssertEqual(HulaConstants.linkedInClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedInState, "")
        XCTAssertEqual(HulaConstants.linkedInRedirectURL, "https://hula.trading/")
    }
    
}
