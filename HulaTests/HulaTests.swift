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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testProductPopulateAcceptsNumericLocationValues() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "location": [
                NSNumber(value: 42.123456789),
                NSNumber(value: -71.987654321)
            ]
        ]
        
        product.populate(with: payload)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 42.123456789, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -71.987654321, accuracy: 0.000000001)
    }
    
    func testProductPopulateAcceptsStringLocationValues() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "location": [
                "42.123456789",
                "-71.987654321"
            ]
        ]
        
        product.populate(with: payload)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 42.123456789, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -71.987654321, accuracy: 0.000000001)
    }
    
    func testProductPopulateIgnoresInvalidLocationValues() {
        let product = HulaProduct()
        let originalLatitude = product.productLocation.coordinate.latitude
        let originalLongitude = product.productLocation.coordinate.longitude
        let payload: NSDictionary = [
            "location": [
                "not-a-coordinate",
                "-71.987654321"
            ]
        ]
        
        product.populate(with: payload)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, originalLatitude)
        XCTAssertEqual(product.productLocation.coordinate.longitude, originalLongitude)
    }
    
    func testProductPopulateIgnoresIncompleteLocationValues() {
        let product = HulaProduct()
        let originalLatitude = product.productLocation.coordinate.latitude
        let originalLongitude = product.productLocation.coordinate.longitude
        let payload: NSDictionary = [
            "location": [
                NSNumber(value: 42.123456789)
            ]
        ]
        
        product.populate(with: payload)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, originalLatitude)
        XCTAssertEqual(product.productLocation.coordinate.longitude, originalLongitude)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
