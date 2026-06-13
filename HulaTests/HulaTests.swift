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
        let preciseLat = 37.7749295123
        let preciseLon = -122.4194155789
        let dict: NSDictionary = [
            "location": [NSNumber(value: preciseLat), NSNumber(value: preciseLon)]
        ]

        product.populate(with: dict)

        assertLocation(product.productLocation, latitude: preciseLat, longitude: preciseLon, accuracy: 1e-9)
    }

    func testProductLocationPopulateAcceptsNSArrayPayload() {
        let product = HulaProduct()
        let coordinates = NSMutableArray()
        coordinates.add(NSNumber(value: 41.878876))
        coordinates.add(NSNumber(value: -87.629798))
        let dict = NSMutableDictionary()
        dict.setObject(coordinates, forKey: "location" as NSCopying)

        product.populate(with: dict)

        assertLocation(product.productLocation, latitude: 41.878876, longitude: -87.629798, accuracy: 1e-6)
    }

    func testProductLocationPopulateAcceptsMixedNumericPayloads() {
        let product = HulaProduct()
        let dict: NSDictionary = [
            "location": [Float(40.712776), Int(-74)]
        ]

        product.populate(with: dict)

        assertLocation(product.productLocation, latitude: Double(Float(40.712776)), longitude: -74.0, accuracy: 1e-6)
    }

    func testProductLocationMalformedPayloadsDoNotOverwriteExistingLocation() {
        assertMalformedLocationPayloadDoesNotOverwrite(["location": [NSNumber(value: 1.5)]])
        assertMalformedLocationPayloadDoesNotOverwrite(["location": ["north", "west"]])
        assertMalformedLocationPayloadDoesNotOverwrite(["location": [true, false]])
        assertMalformedLocationPayloadDoesNotOverwrite(["location": "37.7,-122.4"])
    }

    private func assertMalformedLocationPayloadDoesNotOverwrite(_ payload: NSDictionary, file: StaticString = #file, line: UInt = #line) {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 3.0, longitude: 4.0)

        product.populate(with: payload)

        assertLocation(product.productLocation, latitude: 3.0, longitude: 4.0, file: file, line: line)
    }

    private func assertLocation(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, accuracy: CLLocationDegrees = 0.0, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: accuracy, file: file, line: line)
    }
}
