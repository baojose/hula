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
        let expectedLatitude = 41.403381234567
        let expectedLongitude = 2.174030987654
        let product = HulaProduct()

        product.populate(with: [
            "location": [expectedLatitude, expectedLongitude]
        ] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, expectedLatitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, expectedLongitude, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresMalformedLocationPayload() {
        let originalLatitude = 10.25
        let originalLongitude = -20.5
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: originalLatitude, longitude: originalLongitude)

        product.populate(with: [
            "location": ["not-a-latitude", 2.174030987654]
        ] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, originalLatitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, originalLongitude, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresIncompleteLocationPayload() {
        let originalLatitude = 10.25
        let originalLongitude = -20.5
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: originalLatitude, longitude: originalLongitude)

        product.populate(with: [
            "location": [41.403381234567]
        ] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, originalLatitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, originalLongitude, accuracy: 0.000000000001)
    }
    
}
