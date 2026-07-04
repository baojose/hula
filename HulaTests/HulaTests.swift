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
        HulaUser.sharedInstance.logout()
        HulaUser.sharedInstance.location = CLLocation(latitude: 0, longitude: 0)
    }

    override func tearDown() {
        HulaUser.sharedInstance.logout()
        HulaUser.sharedInstance.location = CLLocation(latitude: 0, longitude: 0)
        super.tearDown()
    }

    func testProductPopulateAcceptsPreciseDoubleLocation() {
        let product = HulaProduct()

        product.populate(with: ["location": [37.785834, -122.406417]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.785834, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.406417, accuracy: 0.000001)
    }

    func testProductPopulateAcceptsBridgedNumericLocation() {
        let product = HulaProduct()
        let coordinates = NSArray(objects: NSNumber(value: 40.7128), NSNumber(value: -74.0060))

        product.populate(with: ["location": coordinates] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0060, accuracy: 0.000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationValues() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(51.5074), -1]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -1.0, accuracy: 0.000001)
    }

    func testProductPopulatePreservesLocationForMalformedPayloads() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: 20.25)
        let malformedPayloads: [NSDictionary] = [
            ["location": []] as NSDictionary,
            ["location": [true, -122.406417]] as NSDictionary,
            ["location": ["37.785834", -122.406417]] as NSDictionary,
            ["location": "37.785834,-122.406417"] as NSDictionary
        ]

        for payload in malformedPayloads {
            product.populate(with: payload)
            XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.000001)
            XCTAssertEqual(product.productLocation.coordinate.longitude, 20.25, accuracy: 0.000001)
        }
    }

    func testSocialCredentialConstantsRemainPublicPlaceholders() {
        XCTAssertTrue(HulaConstants.twitterKey.isEmpty)
        XCTAssertTrue(HulaConstants.twitterSecret.isEmpty)
        XCTAssertTrue(HulaConstants.linkedInClientId.isEmpty)
        XCTAssertTrue(HulaConstants.linkedInClientSecret.isEmpty)
        XCTAssertTrue(HulaConstants.linkedInState.isEmpty)
        XCTAssertEqual(HulaConstants.linkedInPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedInRedirectURL, "https://hula.trading/")
    }
}
