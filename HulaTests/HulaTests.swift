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

    func testProductPopulatePreservesDoublePrecisionLocation() {
        let product = HulaProduct()

        product.populate(with: [
            "location": [
                40.712776123456,
                -74.005974987654
            ]
        ])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.712776123456, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.005974987654, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsArrayBackedByNSNumbers() {
        let product = HulaProduct()

        product.populate(with: [
            "location": NSArray(objects: NSNumber(value: 51.5074), NSNumber(value: -0.1278))
        ])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.1278, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationComponents() {
        let product = HulaProduct()

        product.populate(with: [
            "location": [
                Float(34.052235),
                Int(-118)
            ]
        ])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 34.052235, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -118.0, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresTooShortLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 12.345, longitude: 67.89)

        product.populate(with: [
            "location": [40.7128]
        ])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.345, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 67.89, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresNonNumericLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 12.345, longitude: 67.89)

        product.populate(with: [
            "location": ["north", "west"]
        ])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.345, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 67.89, accuracy: 0.000000000001)
    }
}
