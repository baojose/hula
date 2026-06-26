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

    func testProductPopulateParsesPreciseNSNumberLocation() {
        let product = HulaProduct()
        let expectedLatitude = 37.7749295123
        let expectedLongitude = -122.4194155789
        let payload: NSDictionary = [
            "location": [NSNumber(value: expectedLatitude), NSNumber(value: expectedLongitude)]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, expectedLatitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, expectedLongitude, accuracy: 0.000000001)
    }

    func testProductPopulateParsesMixedNumericLocationPayloads() {
        let product = HulaProduct()
        let location: [Any] = [Float(40.712776), Int(-74)]
        let payload: NSDictionary = [
            "location": location
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, Double(Float(40.712776)), accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0, accuracy: 0.000001)
    }

    func testProductPopulateParsesNSArrayLocationPayload() {
        let product = HulaProduct()
        let location = NSMutableArray()
        location.add(NSNumber(value: 41.878876))
        location.add(NSNumber(value: -87.629798))
        let payload = NSMutableDictionary()
        payload.setObject(location, forKey: "location" as NSCopying)

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 41.878876, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -87.629798, accuracy: 0.000001)
    }

    func testProductPopulatePreservesExistingLocationForMalformedPayloads() {
        assertMalformedLocationPayloadDoesNotOverwrite(["location": [NSNumber(value: 1.0)]])
        assertMalformedLocationPayloadDoesNotOverwrite(["location": ["north", "west"]])
        assertMalformedLocationPayloadDoesNotOverwrite(["location": [true, false]])
        assertMalformedLocationPayloadDoesNotOverwrite(["location": "37.7,-122.4"])
        assertMalformedLocationPayloadDoesNotOverwrite([:])
    }

    func testSocialCredentialConfigurationUsesPublicPlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "linkedin_oauth_state")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectURL, "https://hula.trading/")
    }

    private func assertMalformedLocationPayloadDoesNotOverwrite(_ payload: NSDictionary, file: StaticString = #file, line: UInt = #line) {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 12.34, longitude: 56.78)

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.34, accuracy: 0.000001, file: file, line: line)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 56.78, accuracy: 0.000001, file: file, line: line)
    }
}
