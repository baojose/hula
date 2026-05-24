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
    
}
