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

    func testProductPopulateKeepsDoubleCoordinatePrecision() {
        let product = HulaProduct()
        let latitude = 37.7749295123
        let longitude = -122.4194155123

        product.populate(with: ["location": [latitude, longitude]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000001)
    }

    func testProductPopulateAcceptsFloatCoordinatePayload() {
        let product = HulaProduct()
        let latitude: Float = 52.520008
        let longitude: Float = 13.404954
        let location: [Float] = [latitude, longitude]

        product.populate(with: ["location": location] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, CLLocationDegrees(latitude), accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, CLLocationDegrees(longitude), accuracy: 0.000001)
    }

    func testProductPopulateIgnoresMalformedLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.25, longitude: -20.75)

        product.populate(with: ["location": [42.0]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.25, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -20.75, accuracy: 0.000000001)

        product.populate(with: ["location": ["north", "west"]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.25, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -20.75, accuracy: 0.000000001)
    }
}
