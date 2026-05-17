//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import CoreLocation
import CoreGraphics
@testable import Hula

class HulaTests: XCTestCase {

    func testProductLocationPopulatePreservesDoublePrecision() {
        let product = HulaProduct()
        let preciseLat = 37.7749295123
        let preciseLon = -122.4194155789
        let dict: NSDictionary = [
            "location": [NSNumber(value: preciseLat), NSNumber(value: preciseLon)]
        ]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, preciseLat, accuracy: 1e-9)
        XCTAssertEqual(product.productLocation.coordinate.longitude, preciseLon, accuracy: 1e-9)
    }

    func testProductLocationPopulateAcceptsFloatArray() {
        let product = HulaProduct()
        let lat = Float(40.712776)
        let lon = Float(-74.005974)
        let dict: NSDictionary = ["location": [lat, lon]]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, Double(lat), accuracy: 1e-6)
        XCTAssertEqual(product.productLocation.coordinate.longitude, Double(lon), accuracy: 1e-6)
    }

    func testProductLocationTooShortArrayDoesNotOverwrite() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 1.0, longitude: 2.0)
        let dict: NSDictionary = ["location": [NSNumber(value: 1.5)]]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 1.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.0)
    }

    func testProductLocationNonNumericDoesNotOverwrite() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 3.0, longitude: 4.0)
        let dict: NSDictionary = ["location": ["north", "west"]]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 3.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 4.0)
    }

    func testProductLocationNSArrayPayloadParses() {
        let product = HulaProduct()
        let arr = NSMutableArray()
        arr.add(NSNumber(value: 41.878876))
        arr.add(NSNumber(value: -87.629798))
        let dict = NSMutableDictionary()
        dict.setObject(arr, forKey: "location" as NSCopying)
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 41.878876, accuracy: 1e-6)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -87.629798, accuracy: 1e-6)
    }

    func testProductLocationPopulateIgnoresExtraArrayValues() {
        let product = HulaProduct()
        let dict: NSDictionary = [
            "location": [NSNumber(value: 48.856613), NSNumber(value: 2.352222), "ignored"]
        ]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 48.856613, accuracy: 1e-6)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.352222, accuracy: 1e-6)
    }

    func testProductLocationPopulateAcceptsIntegerComponents() {
        let product = HulaProduct()
        let dict: NSDictionary = [
            "location": [Int32(52), Int64(13)]
        ]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 52.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 13.0)
    }

    func testProductLocationPopulateAcceptsCGFloatComponents() {
        let product = HulaProduct()
        let lat = CGFloat(34.052235)
        let lon = CGFloat(-118.243683)
        let dict: NSDictionary = ["location": [lat, lon]]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, Double(lat), accuracy: 1e-9)
        XCTAssertEqual(product.productLocation.coordinate.longitude, Double(lon), accuracy: 1e-9)
    }

    func testProductLocationMixedValidityDoesNotOverwrite() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 5.0, longitude: 6.0)
        let dict: NSDictionary = ["location": [NSNumber(value: 7.0), "invalid"]]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 5.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 6.0)
    }

    func testProductLocationNonArrayPayloadDoesNotOverwrite() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 7.0, longitude: 8.0)
        let dict: NSDictionary = ["location": "52.0,13.0"]
        product.populate(with: dict)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 7.0)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 8.0)
    }
}
