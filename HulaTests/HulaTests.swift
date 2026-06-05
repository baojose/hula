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

    func testProductPopulatePreservesDoublePrecisionLocation() {
        let product = HulaProduct()

        product.populate(with: ["location": [37.785834000123, -122.406417000456]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.785834000123, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.406417000456, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsArrayBridgedFromJSONSerialization() {
        let product = HulaProduct()
        let location = NSArray(array: [NSNumber(value: 51.5074), NSNumber(value: -0.1278)])

        product.populate(with: ["location": location])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.1278, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(19.4326), -99]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 19.4326, accuracy: 0.00001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -99.0, accuracy: 0.000000000001)
    }

    func testProductPopulateKeepsExistingLocationWhenPayloadIsTooShort() {
        let product = HulaProduct()
        product.populate(with: ["location": [40.7128, -74.0060]])

        product.populate(with: ["location": [34.0522]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0060, accuracy: 0.000000000001)
    }

    func testProductPopulateKeepsExistingLocationWhenPayloadIsNonNumeric() {
        let product = HulaProduct()
        product.populate(with: ["location": [40.7128, -74.0060]])

        product.populate(with: ["location": ["not-a-latitude", "not-a-longitude"]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0060, accuracy: 0.000000000001)
    }

    func testProductPopulateKeepsExistingLocationWhenPayloadContainsBooleans() {
        let product = HulaProduct()
        product.populate(with: ["location": [40.7128, -74.0060]])

        product.populate(with: ["location": [true, false]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0060, accuracy: 0.000000000001)
    }
}
