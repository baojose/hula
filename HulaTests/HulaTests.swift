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

    func testProductPopulatePreservesDoublePrecisionCoordinates() {
        let product = HulaProduct()
        let latitude = 37.774929512345
        let longitude = -122.419415512345

        product.populate(with: ["location": [latitude, longitude]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsNSArrayLocationFromJSONSerialization() {
        let product = HulaProduct()
        let payload = NSArray(objects: NSNumber(value: 51.507351), NSNumber(value: -0.127758))

        product.populate(with: ["location": payload])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.507351, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.127758, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsIntegerAndFloatCoordinateValues() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(40.7128), -74]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresTooShortLocationWithoutOverwritingExistingValue() {
        let product = HulaProduct()
        let existingLocation = CLLocation(latitude: 12.34, longitude: 56.78)
        product.productLocation = existingLocation

        product.populate(with: ["location": [99.99]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, existingLocation.coordinate.latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, existingLocation.coordinate.longitude, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresNonNumericLocationWithoutOverwritingExistingValue() {
        let product = HulaProduct()
        let existingLocation = CLLocation(latitude: 12.34, longitude: 56.78)
        product.productLocation = existingLocation

        product.populate(with: ["location": ["north", "west"]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, existingLocation.coordinate.latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, existingLocation.coordinate.longitude, accuracy: 0.000000000001)
    }
}
