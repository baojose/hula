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

    func testProductPopulateAcceptsPreciseAndBridgedCoordinates() {
        let product = HulaProduct()

        product.populate(with: ["location": [12.3456789012345, -98.7654321098765]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.3456789012345, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -98.7654321098765, accuracy: 0.000000000001)

        product.populate(with: ["location": NSArray(objects: NSNumber(value: 41.5), NSNumber(value: -73.25))] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 41.5, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -73.25, accuracy: 0.000000000001)
    }

    func testProductPopulatePreservesLocationForMalformedCoordinates() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 9.25, longitude: -70.75)

        product.populate(with: ["location": [true, false]] as NSDictionary)
        assertCoordinate(product.productLocation, latitude: 9.25, longitude: -70.75)

        product.populate(with: ["location": [42.0]] as NSDictionary)
        assertCoordinate(product.productLocation, latitude: 9.25, longitude: -70.75)

        product.populate(with: ["location": "not-an-array"] as NSDictionary)
        assertCoordinate(product.productLocation, latitude: 9.25, longitude: -70.75)
    }

    func testUserPopulateAcceptsBridgedCoordinatesAndPreservesInvalidPayloads() {
        let user = HulaUser()

        user.populate(with: ["location": NSArray(objects: NSNumber(value: 37.332), NSNumber(value: -122.031))] as NSDictionary)
        assertCoordinate(user.location, latitude: 37.332, longitude: -122.031)

        user.populate(with: ["location": [false, true]] as NSDictionary)
        assertCoordinate(user.location, latitude: 37.332, longitude: -122.031)

        user.populate(with: ["location": []] as NSDictionary)
        assertCoordinate(user.location, latitude: 37.332, longitude: -122.031)
    }

    func testTradeLoadFromHandlesEmptyAndPopulatedBids() {
        let trade = HulaTrade()
        trade.last_bid_diff = ["stale-owner", "stale-other"]
        trade.num_bids = 2

        trade.loadFrom(dict: ["bids": []] as NSDictionary)

        XCTAssertEqual(trade.num_bids, 0)
        XCTAssertTrue(trade.last_bid_diff.isEmpty)

        trade.loadFrom(dict: ["bids": [["owner_diff": ["owner-product"], "other_diff": ["other-product"]]]] as NSDictionary)

        XCTAssertEqual(trade.num_bids, 1)
        XCTAssertEqual(trade.last_bid_diff, ["owner-product", "other-product"])
    }

    func testCommittedSocialCredentialPlaceholdersAreEmpty() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectURL, "https://hula.trading/")
    }

    private func assertCoordinate(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.000000000001, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.000000000001, file: file, line: line)
    }

}
