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

    func testPublicOAuthCredentialsArePlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectURL, HulaConstants.staticServerURL + "/")
    }

    func testProductPopulateAcceptsPreciseDoubleLocation() {
        let product = HulaProduct()

        product.populate(with: ["location": [37.785834, -122.406417] as [Double]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.785834, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.406417, accuracy: 0.0000001)
    }

    func testProductPopulateAcceptsBridgedNSNumberLocation() {
        let product = HulaProduct()
        let bridgedLocation = NSArray(array: [NSNumber(value: 40.7128), NSNumber(value: -74.0060)])

        product.populate(with: ["location": bridgedLocation] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0060, accuracy: 0.0000001)
    }

    func testProductPopulateAcceptsMixedNumericLocation() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(51.5074), -1] as [Any]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.00001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -1.0, accuracy: 0.0000001)
    }

    func testProductPopulatePreservesExistingLocationForMalformedPayloads() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 12.34, longitude: 56.78)

        product.populate(with: ["location": [37.0] as [Any]] as NSDictionary)
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)

        product.populate(with: ["location": ["bad", -122.0] as [Any]] as NSDictionary)
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)

        product.populate(with: ["location": [true, false] as [Any]] as NSDictionary)
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)

        product.populate(with: ["location": "not-array"] as NSDictionary)
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)
    }

    private func assertLocation(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.0000001, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.0000001, file: file, line: line)
    }
}
