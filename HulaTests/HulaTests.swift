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

    func testProductLocationPopulatePreservesDoublePrecision() {
        let product = HulaProduct()
        let preciseLatitude = 37.7749295123
        let preciseLongitude = -122.4194155789
        let dict: NSDictionary = [
            "location": [NSNumber(value: preciseLatitude), NSNumber(value: preciseLongitude)]
        ]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, preciseLatitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, preciseLongitude, accuracy: 0.000000001)
    }

    func testProductLocationPopulateAcceptsNSArrayPayload() {
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

    func testProductLocationPopulateAcceptsMixedNumericPayload() {
        let product = HulaProduct()
        let latitude = Float(40.712776)
        let longitude = -74
        let dict: NSDictionary = ["location": [latitude, longitude]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, Double(latitude), accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, Double(longitude), accuracy: 0.000001)
    }

    func testProductLocationTooShortArrayDoesNotOverwriteExistingLocation() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 1.0, longitude: 2.0)
        let dict: NSDictionary = ["location": [NSNumber(value: 1.5)]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 1.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.0)
    }

    func testProductLocationEmptyArrayDoesNotOverwriteExistingLocation() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 3.0, longitude: 4.0)
        let dict: NSDictionary = ["location": []]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 3.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 4.0)
    }

    func testProductLocationNonNumericPayloadDoesNotOverwriteExistingLocation() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 5.0, longitude: 6.0)
        let dict: NSDictionary = ["location": ["north", "west"]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 5.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 6.0)
    }

    func testProductLocationBooleanPayloadDoesNotOverwriteExistingLocation() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 7.0, longitude: 8.0)
        let dict: NSDictionary = ["location": [true, false]]

        product.populate(with: dict)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 7.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 8.0)
    }
}
