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

    private func productWithLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> HulaProduct {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: latitude, longitude: longitude)
        return product
    }

    func testProductPopulatePreservesDoublePrecisionLocation() {
        let product = HulaProduct()
        let latitude = 37.785834123
        let longitude = -122.406417987

        product.populate(with: NSDictionary(dictionary: [
            "location": [latitude, longitude]
        ]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000001)
    }

    func testProductPopulateAcceptsNSArrayLocationPayload() {
        let product = HulaProduct()
        let latitude = 41.40338
        let longitude = 2.17403

        product.populate(with: NSDictionary(dictionary: [
            "location": NSArray(array: [
                NSNumber(value: latitude),
                NSNumber(value: longitude)
            ])
        ]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()

        product.populate(with: NSDictionary(dictionary: [
            "location": [Float(48.8566), Int(2)] as [Any]
        ]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, 48.8566, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.0, accuracy: 0.000001)
    }

    func testProductPopulateIgnoresTooShortLocationPayload() {
        let product = productWithLocation(latitude: 10.25, longitude: -20.5)

        product.populate(with: NSDictionary(dictionary: [
            "location": [99.0]
        ]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.25, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -20.5, accuracy: 0.000000001)
    }

    func testProductPopulateIgnoresNonNumericLocationPayload() {
        let product = productWithLocation(latitude: -33.86, longitude: 151.21)

        product.populate(with: NSDictionary(dictionary: [
            "location": ["north", "east"]
        ]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, -33.86, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 151.21, accuracy: 0.000000001)
    }

    func testProductPopulateIgnoresBooleanLocationPayload() {
        let product = productWithLocation(latitude: 52.52, longitude: 13.405)

        product.populate(with: NSDictionary(dictionary: [
            "location": [NSNumber(value: true), NSNumber(value: false)]
        ]))

        XCTAssertEqual(product.productLocation.coordinate.latitude, 52.52, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 13.405, accuracy: 0.000000001)
    }
}
