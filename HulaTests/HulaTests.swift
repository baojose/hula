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
    
    func testProductPopulatePreservesHighPrecisionLocationCoordinates() {
        let product = HulaProduct()
        let latitude = 37.7749295123
        let longitude = -122.4194155123
        let payload: NSDictionary = [
            "location": [
                NSNumber(value: latitude),
                NSNumber(value: longitude)
            ]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.0000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.0000000001)
    }

    func testProductPopulateLeavesLocationUnchangedForIncompleteLocationArray() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: -20.5)
        let payload: NSDictionary = [
            "location": [
                NSNumber(value: 37.7749295123)
            ]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.0000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -20.5, accuracy: 0.0000000001)
    }

    func testProductPopulateLeavesLocationUnchangedForNonNumericCoordinates() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: -20.5)
        let payload: NSDictionary = [
            "location": [
                "not-a-coordinate",
                NSNumber(value: -122.4194155123)
            ]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.0000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -20.5, accuracy: 0.0000000001)
    }
    
}
