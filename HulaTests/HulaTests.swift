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

    func testProductPopulateAcceptsPreciseSwiftCoordinates() {
        let product = HulaProduct()
        let latitude = 47.620506112233
        let longitude = -122.349277445566

        product.populate(with: dictionary(location: [latitude, longitude]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsBridgedNumberCoordinates() {
        let product = HulaProduct()
        let location = NSArray(objects: NSNumber(value: 47.6205), NSNumber(value: -122.3493))

        product.populate(with: dictionary(location: location))

        XCTAssertEqual(product.productLocation.coordinate.latitude, 47.6205, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.3493, accuracy: 0.0000001)
    }

    func testProductPopulatePreservesExistingLocationForMalformedCoordinates() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 12.34, longitude: -56.78)

        product.populate(with: dictionary(location: [12.34]))
        product.populate(with: dictionary(location: ["north", -56.78]))
        product.populate(with: dictionary(location: [true, -56.78]))
        product.populate(with: dictionary(location: "not-array"))

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.34, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -56.78, accuracy: 0.0000001)
    }

    func testUserPopulateAcceptsBridgedNumberCoordinates() {
        let user = HulaUser()
        let location = NSArray(objects: NSNumber(value: 40.7128), NSNumber(value: -74.0060))

        user.populate(with: dictionary(location: location))

        XCTAssertEqual(user.location.coordinate.latitude, 40.7128, accuracy: 0.0000001)
        XCTAssertEqual(user.location.coordinate.longitude, -74.0060, accuracy: 0.0000001)
    }

    func testUserPopulatePreservesExistingLocationForMalformedCoordinates() {
        let user = HulaUser()
        user.location = CLLocation(latitude: 34.0522, longitude: -118.2437)

        user.populate(with: dictionary(location: [34.0522]))
        user.populate(with: dictionary(location: ["west", -118.2437]))
        user.populate(with: dictionary(location: [false, -118.2437]))
        user.populate(with: dictionary(location: "not-array"))

        XCTAssertEqual(user.location.coordinate.latitude, 34.0522, accuracy: 0.0000001)
        XCTAssertEqual(user.location.coordinate.longitude, -118.2437, accuracy: 0.0000001)
    }

    func testTradeLoadFromEmptyBidsResetsBidState() {
        let trade = HulaTrade()
        trade.num_bids = 2
        trade.last_bid_diff = ["stale-owner", "stale-other"]

        trade.loadFrom(dict: NSDictionary(dictionary: ["bids": [] as [Any]]))

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertTrue(trade.last_bid_diff.isEmpty)
    }

    func testTradeLoadFromUsesLastBidDiffs() {
        let trade = HulaTrade()
        let bids: [[String: Any]] = [
            ["owner_diff": ["old-owner"], "other_diff": ["old-other"]],
            ["owner_diff": ["new-owner"], "other_diff": ["new-other", "bonus"]]
        ]

        trade.loadFrom(dict: NSDictionary(dictionary: ["bids": bids]))

        XCTAssertEqual(trade.num_bids, 2)
        XCTAssertEqual(trade.last_bid_diff, ["new-owner", "new-other", "bonus"])
    }

    func testCommittedSocialCredentialConstantsArePlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "DLKDJF46ikMMZADfdfds")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectURL, "https://hula.trading/")
    }

    private func dictionary(location: Any) -> NSDictionary {
        return NSDictionary(dictionary: ["location": location])
    }
}
