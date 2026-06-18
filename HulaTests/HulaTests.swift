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

    private func assertCoordinate(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.0000001, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.0000001, file: file, line: line)
    }

    func testProductPopulatePreservesDoublePrecisionLocation() {
        let product = HulaProduct()
        let latitude = 37.7749295
        let longitude = -122.4194155

        product.populate(with: ["location": [latitude, longitude]] as NSDictionary)

        assertCoordinate(product.productLocation, latitude: latitude, longitude: longitude)
    }

    func testProductPopulateAcceptsBridgedAndMixedNumericLocationPayloads() {
        let bridgedProduct = HulaProduct()
        let bridgedPayload = ["location": NSArray(array: [NSNumber(value: 40.7128), NSNumber(value: -74.0060)])] as NSDictionary

        bridgedProduct.populate(with: bridgedPayload)

        assertCoordinate(bridgedProduct.productLocation, latitude: 40.7128, longitude: -74.0060)

        let mixedProduct = HulaProduct()
        mixedProduct.populate(with: ["location": [Float(51.5074), -1]] as NSDictionary)

        assertCoordinate(mixedProduct.productLocation, latitude: 51.5074, longitude: -1.0)
    }

    func testProductPopulatePreservesExistingLocationForMalformedPayloads() {
        let product = HulaProduct()
        let latitude = 12.5
        let longitude = -44.25
        product.productLocation = CLLocation(latitude: latitude, longitude: longitude)

        let malformedPayloads: [NSDictionary] = [
            ["location": [1.0]],
            ["location": ["not-a-number", -122.0]],
            ["location": [true, false]],
            ["location": "not-an-array"]
        ]

        for payload in malformedPayloads {
            product.populate(with: payload)
            assertCoordinate(product.productLocation, latitude: latitude, longitude: longitude)
        }
    }

    func testPublicSnapshotDoesNotEmbedSocialOAuthSecrets() {
        XCTAssertTrue(HulaConstants.twitterKey.isEmpty)
        XCTAssertTrue(HulaConstants.twitterSecret.isEmpty)
        XCTAssertTrue(HulaConstants.linkedinClientId.isEmpty)
        XCTAssertTrue(HulaConstants.linkedinClientSecret.isEmpty)
    }

    func testLinkedinConfigurationUsesCentralizedPublicSnapshotValues() {
        let configuration = HulaConstants.linkedinConfiguration

        XCTAssertEqual(configuration.clientId, HulaConstants.linkedinClientId)
        XCTAssertEqual(configuration.clientSecret, HulaConstants.linkedinClientSecret)
        XCTAssertEqual(configuration.state, HulaConstants.linkedinState)
        XCTAssertEqual(configuration.redirectUrl, HulaConstants.linkedinRedirectURL)
        XCTAssertEqual(configuration.permissions as? [String], HulaConstants.linkedinPermissions)
    }
}
