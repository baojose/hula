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
    
    func testProductPopulatePreservesPreciseDoubleLocation() {
        let product = HulaProduct()
        let latitude = 37.774929512345
        let longitude = -122.419415512345

        product.populate(with: ["location": [latitude, longitude]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsNSArrayNumberLocation() {
        let product = HulaProduct()
        let location = NSArray(array: [NSNumber(value: 40.712776), NSNumber(value: -74.005974)])

        product.populate(with: ["location": location])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.712776, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.005974, accuracy: 0.000000000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationValues() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(12.5), 45]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.5, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 45.0, accuracy: 0.000001)
    }

    func testProductPopulateIgnoresTooShortLocationPayload() {
        let product = productWithLocation(latitude: 8.25, longitude: -9.5)

        product.populate(with: ["location": [42.0]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 8.25, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -9.5, accuracy: 0.000001)
    }

    func testProductPopulateIgnoresNonNumericLocationPayload() {
        let product = productWithLocation(latitude: 15.75, longitude: -20.25)

        product.populate(with: ["location": ["north", "west"]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 15.75, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -20.25, accuracy: 0.000001)
    }

    func testProductPopulateIgnoresBooleanLocationPayload() {
        let product = productWithLocation(latitude: 31.5, longitude: -80.5)

        product.populate(with: ["location": [true, false]])

        XCTAssertEqual(product.productLocation.coordinate.latitude, 31.5, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -80.5, accuracy: 0.000001)
    }

    private func productWithLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> HulaProduct {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: latitude, longitude: longitude)
        return product
    }
    
}
