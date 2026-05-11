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
    
    func testProductPopulateAcceptsDoubleLocation() {
        let product = HulaProduct()
        let data: NSDictionary = ["location": [37.7749, -122.4194]]
        
        product.populate(with: data)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.7749, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.4194, accuracy: 0.000001)
    }
    
    func testProductPopulateAcceptsFloatLocation() {
        let product = HulaProduct()
        let data: NSDictionary = ["location": [Float(37.5), Float(-122.5)]]
        
        product.populate(with: data)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.5, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.5, accuracy: 0.000001)
    }
    
    func testProductPopulateIgnoresMalformedLocation() {
        let product = HulaProduct()
        let data: NSDictionary = ["location": ["bad-coordinate", NSNull()]]
        
        product.populate(with: data)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 0.0, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 0.0, accuracy: 0.000001)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
