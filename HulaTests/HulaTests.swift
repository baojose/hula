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

    func testProductPopulatePreservesPreciseLocationCoordinates() {
        let product = HulaProduct()
        let latitude = 37.7749295123
        let longitude = -122.4194155789
        let dict: NSDictionary = [
            "location": [NSNumber(value: latitude), NSNumber(value: longitude)]
        ]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000001)
    }

    func testProductPopulateAcceptsFloatLocationCoordinates() {
        let product = HulaProduct()
        let latitude = Float(40.712776)
        let longitude = Float(-74.005974)
        let dict: NSDictionary = ["location": [latitude, longitude]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, Double(latitude), accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, Double(longitude), accuracy: 0.000001)
    }

    func testProductPopulateAcceptsNSArrayLocationPayload() {
        let product = HulaProduct()
        let location = NSMutableArray()
        location.add(NSNumber(value: 41.878876))
        location.add(NSNumber(value: -87.629798))
        let dict = NSMutableDictionary()
        dict.setObject(location, forKey: "location" as NSCopying)

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 41.878876, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -87.629798, accuracy: 0.000001)
    }

    func testProductPopulateIgnoresIncompleteLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 1.0, longitude: 2.0)
        let dict: NSDictionary = ["location": [NSNumber(value: 1.5)]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 1.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.0)
    }

    func testProductPopulateIgnoresNonNumericLocationPayload() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 3.0, longitude: 4.0)
        let dict: NSDictionary = ["location": ["north", "west"]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 3.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 4.0)
    }

}
