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
    
    func testProductPopulateAcceptsFloatLocationValues() {
        let product = HulaProduct()
        
        product.populate(with: ["location": [Float(40.4168), Float(-3.7038)]] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, CLLocationDegrees(Float(40.4168)), accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, CLLocationDegrees(Float(-3.7038)), accuracy: 0.0001)
    }
    
    func testProductPopulateIgnoresInvalidLocationValues() {
        let product = HulaProduct()
        
        product.populate(with: ["location": [NSNull(), NSNull()]] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 0.0, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 0.0, accuracy: 0.0001)
    }
    
}
