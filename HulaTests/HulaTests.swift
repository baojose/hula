//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
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
    
    func testProductPopulateReadsDoubleCoordinates() {
        let product = HulaProduct()
        
        product.populate(with: ["location": [12.5, -45.25]] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.5, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -45.25, accuracy: 0.000001)
    }
    
    func testProductPopulateReadsNumberCoordinates() {
        let product = HulaProduct()
        
        product.populate(with: ["location": [NSNumber(value: 12.5), NSNumber(value: -45.25)]] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.5, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -45.25, accuracy: 0.000001)
    }
    
    func testProductPopulateIgnoresMalformedCoordinates() {
        let product = HulaProduct()
        
        product.populate(with: ["location": ["bad", NSNull()]] as NSDictionary)
        product.populate(with: ["location": [12.5]] as NSDictionary)
        
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
