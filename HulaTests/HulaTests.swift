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
        let payload = ["location": [37.7749295, -122.4194155]] as NSDictionary

        product.populate(with: payload)

        assertCoordinate(product.productLocation.coordinate.latitude, equals: 37.7749295)
        assertCoordinate(product.productLocation.coordinate.longitude, equals: -122.4194155)
    }

    func testProductPopulateAcceptsNSArrayLocationPayload() {
        let product = HulaProduct()
        let payload = ["location": NSArray(objects: NSNumber(value: 40.7128), NSNumber(value: -74.0060))] as NSDictionary

        product.populate(with: payload)

        assertCoordinate(product.productLocation.coordinate.latitude, equals: 40.7128)
        assertCoordinate(product.productLocation.coordinate.longitude, equals: -74.0060)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()
        let floatLongitude = Float(-87.6298)
        let payload = ["location": [41, floatLongitude]] as NSDictionary

        product.populate(with: payload)

        assertCoordinate(product.productLocation.coordinate.latitude, equals: 41.0)
        assertCoordinate(product.productLocation.coordinate.longitude, equals: Double(floatLongitude))
    }

    func testProductPopulateIgnoresTooShortLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 34.0522, longitude: -118.2437)

        product.populate(with: ["location": [51.5074]] as NSDictionary)

        assertCoordinate(product.productLocation.coordinate.latitude, equals: 34.0522)
        assertCoordinate(product.productLocation.coordinate.longitude, equals: -118.2437)
    }

    func testProductPopulateIgnoresNonNumericLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 47.6062, longitude: -122.3321)

        product.populate(with: ["location": ["north", "west"]] as NSDictionary)

        assertCoordinate(product.productLocation.coordinate.latitude, equals: 47.6062)
        assertCoordinate(product.productLocation.coordinate.longitude, equals: -122.3321)
    }

    private func assertCoordinate(_ actual: CLLocationDegrees, equals expected: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(actual, expected, accuracy: 0.0000001, file: file, line: line)
    }
}
