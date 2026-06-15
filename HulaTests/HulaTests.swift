//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import CoreLocation
import LinkedinSwift
@testable import Hula

class HulaTests: XCTestCase {

    func testProductPopulateAcceptsPreciseDoubleLocation() {
        let product = HulaProduct()
        let latitude = 37.7749295123
        let longitude = -122.4194155123

        product.populate(with: ["location": [latitude, longitude]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000001)
    }

    func testProductPopulateAcceptsBridgedAndMixedNumericLocations() {
        let product = HulaProduct()
        let bridgedLocation = NSArray(objects: NSNumber(value: 40.712776), NSNumber(value: -74.005974))

        product.populate(with: ["location": bridgedLocation])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.712776, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.005974, accuracy: 0.000000001)

        let mixedLocation: [Any] = [Float(51.5074), -1]
        product.populate(with: ["location": mixedLocation])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -1.0, accuracy: 0.000000001)
    }

    func testProductPopulatePreservesExistingLocationForMalformedPayloads() {
        let product = HulaProduct()
        let originalLocation = CLLocation(latitude: 12.345, longitude: 67.89)
        let malformedPayloads: [NSDictionary] = [
            ["location": [45.0]],
            ["location": ["north", "west"]],
            ["location": [true, false]],
            ["location": "37.0,-122.0"]
        ]

        for payload in malformedPayloads {
            product.productLocation = originalLocation
            product.populate(with: payload)

            XCTAssertEqual(product.productLocation.coordinate.latitude, originalLocation.coordinate.latitude, accuracy: 0.000000001)
            XCTAssertEqual(product.productLocation.coordinate.longitude, originalLocation.coordinate.longitude, accuracy: 0.000000001)
        }
    }

    func testSocialCredentialConstantsRemainPublicPlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "REPLACE_ME_LINKEDIN_STATE")
        XCTAssertTrue(HulaConstants.linkedinState.hasPrefix("REPLACE_ME"))
    }

    func testProfileLinkedinConfigurationUsesCentralizedPlaceholders() {
        let configuration = HLProfileViewController.linkedinConfiguration()

        XCTAssertEqual(configuration.clientId, HulaConstants.linkedinClientId)
        XCTAssertEqual(configuration.clientSecret, HulaConstants.linkedinClientSecret)
        XCTAssertEqual(configuration.state, HulaConstants.linkedinState)
        XCTAssertEqual(configuration.permissions as? [String] ?? [], HulaConstants.linkedinPermissions)
        XCTAssertEqual(configuration.redirectUrl, HulaConstants.linkedinRedirectURL)
    }

}
