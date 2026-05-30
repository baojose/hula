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

    func testProductPopulatePreservesDoublePrecisionLocation() {
        let product = HulaProduct()
        let payload: NSDictionary = ["location": [37.7749295, -122.4194155]]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.7749295, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.4194155, accuracy: 0.0000001)
    }

    func testProductPopulateAcceptsNSArrayLocationPayload() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "location": NSArray(array: [
                NSNumber(value: 40.712776),
                NSNumber(value: -74.005974)
            ])
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.712776, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.005974, accuracy: 0.0000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()
        let payload: NSDictionary = ["location": [Float(51.5074), Int(-1)]]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -1.0, accuracy: 0.0000001)
    }

    func testProductPopulateIgnoresTooShortLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: 20.5)
        let payload: NSDictionary = ["location": [99.0]]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 20.5, accuracy: 0.0000001)
    }

    func testProductPopulateIgnoresNonNumericLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: 20.5)
        let payload: NSDictionary = ["location": ["north", -122.4194155]]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 20.5, accuracy: 0.0000001)
    }

    func testProductPopulateIgnoresBooleanLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: 20.5)
        let payload: NSDictionary = ["location": [true, false]]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 20.5, accuracy: 0.0000001)
    }
}
