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

    func testProductPopulateKeepsDoublePrecisionCoordinates() {
        let product = HulaProduct()

        product.populate(with: ["location": [37.7749295, -122.4194155]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.7749295, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.4194155, accuracy: 0.0000001)
    }

    func testProductPopulateAcceptsBridgedNumberCoordinates() {
        let product = HulaProduct()
        let location = NSArray(objects: NSNumber(value: 40.712776), NSNumber(value: -74.005974))

        product.populate(with: ["location": location] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.712776, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.005974, accuracy: 0.0000001)
    }

    func testProductPopulateAcceptsMixedNumericCoordinates() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(51.5074), -1] as [Any]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -1.0, accuracy: 0.0000001)
    }

    func testProductPopulatePreservesLocationForMalformedCoordinates() {
        let product = HulaProduct()
        let originalLocation = CLLocation(latitude: 12.34, longitude: 56.78)
        product.productLocation = originalLocation
        let malformedPayloads: [Any] = [
            [37.0] as [Any],
            ["north", -122.0] as [Any],
            [true, false] as [Any],
            "37,-122",
            NSNull()
        ]

        for payload in malformedPayloads {
            product.populate(with: ["location": payload] as NSDictionary)

            XCTAssertEqual(product.productLocation.coordinate.latitude, originalLocation.coordinate.latitude, accuracy: 0.000001)
            XCTAssertEqual(product.productLocation.coordinate.longitude, originalLocation.coordinate.longitude, accuracy: 0.000001)
        }
    }

    func testSocialCredentialConstantsArePublicPlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "")

        XCTAssertEqual(HulaConstants.linkedinRedirectURL, "https://hula.trading/")
        XCTAssertTrue(HulaConstants.linkedinPermissions.contains("r_basicprofile"))
        XCTAssertTrue(HulaConstants.linkedinPermissions.contains("r_emailaddress"))
    }
}
