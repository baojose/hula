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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProductPopulateParsesPreciseDoubleLocation() {
        let product = HulaProduct()
        let payload: NSDictionary = ["location": [37.7749295, -122.4194155]]

        product.populate(with: payload)

        assertLocation(product.productLocation, latitude: 37.7749295, longitude: -122.4194155)
    }

    func testProductPopulateParsesNSArrayBackedNSNumberLocation() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "location": NSArray(array: [
                NSNumber(value: 41.3850639),
                NSNumber(value: 2.1734035)
            ])
        ]

        product.populate(with: payload)

        assertLocation(product.productLocation, latitude: 41.3850639, longitude: 2.1734035)
    }

    func testProductPopulateParsesMixedNumericLocation() {
        let product = HulaProduct()
        let payload: NSDictionary = ["location": [Float(48.5), -2]]

        product.populate(with: payload)

        assertLocation(product.productLocation, latitude: 48.5, longitude: -2.0)
    }

    func testProductPopulateIgnoresMalformedLocationPayloads() {
        let malformedPayloads: [NSDictionary] = [
            ["location": [10.0]],
            ["location": ["10.0", 20.0]],
            ["location": [true, false]],
            ["location": "10.0,20.0"]
        ]

        for payload in malformedPayloads {
            let product = HulaProduct()
            product.productLocation = CLLocation(latitude: 12.3456, longitude: 65.4321)

            product.populate(with: payload)

            assertLocation(product.productLocation, latitude: 12.3456, longitude: 65.4321)
        }
    }

    private func assertLocation(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.000001)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.000001)
    }
    
}
