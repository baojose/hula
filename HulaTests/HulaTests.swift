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
        let latitude = 37.774929123456
        let longitude = -122.419415987654

        product.populate(with: ["location": [latitude, longitude]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsNSArrayNumberLocationPayload() {
        let product = HulaProduct()
        let location = NSArray(array: [NSNumber(value: 51.507351), NSNumber(value: -0.127758)])

        product.populate(with: ["location": location] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.507351, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.127758, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(48.8566), Int(2)] as [Any]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 48.8566, accuracy: 0.00001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.0, accuracy: 0.000000000001)
    }

    func testProductPopulateIgnoresMalformedLocationPayloads() {
        let malformedPayloads: [Any] = [
            [12.34],
            ["12.34", "-56.78"],
            [true, false],
            "12.34,-56.78"
        ]

        for payload in malformedPayloads {
            let product = HulaProduct()
            product.productLocation = CLLocation(latitude: 10.5, longitude: -20.25)

            product.populate(with: ["location": payload] as NSDictionary)

            XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.000000000001)
            XCTAssertEqual(product.productLocation.coordinate.longitude, -20.25, accuracy: 0.000000000001)
        }
    }

}
