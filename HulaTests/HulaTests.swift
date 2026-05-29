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
    
    func testProductPopulatePreservesDoublePrecisionLocation() {
        let product = HulaProduct()
        let latitude = 37.7749295
        let longitude = -122.4194155
        
        product.populate(with: ["location": [latitude, longitude]] as NSDictionary)
        
        assertLocation(product.productLocation, latitude: latitude, longitude: longitude)
    }
    
    func testProductPopulateAcceptsNSArrayLocationPayload() {
        let product = HulaProduct()
        let location = NSArray(objects: NSNumber(value: 45.5016889), NSNumber(value: -73.567256))
        
        product.populate(with: ["location": location] as NSDictionary)
        
        assertLocation(product.productLocation, latitude: 45.5016889, longitude: -73.567256)
    }
    
    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()
        
        product.populate(with: ["location": [Float(51.5074), -1]] as NSDictionary)
        
        assertLocation(product.productLocation, latitude: 51.5074, longitude: -1.0)
    }
    
    func testProductPopulateKeepsExistingLocationForTooShortPayload() {
        let product = productWithLocation(latitude: 12.34, longitude: 56.78)
        
        product.populate(with: ["location": [90.0]] as NSDictionary)
        
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)
    }
    
    func testProductPopulateKeepsExistingLocationForNonNumericPayload() {
        let product = productWithLocation(latitude: 12.34, longitude: 56.78)
        
        product.populate(with: ["location": ["north", "west"]] as NSDictionary)
        
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)
    }
    
    func testProductPopulateKeepsExistingLocationForBooleanPayload() {
        let product = productWithLocation(latitude: 12.34, longitude: 56.78)
        
        product.populate(with: ["location": [true, false]] as NSDictionary)
        
        assertLocation(product.productLocation, latitude: 12.34, longitude: 56.78)
    }
    
    private func productWithLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> HulaProduct {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: latitude, longitude: longitude)
        return product
    }
    
    private func assertLocation(_ location: CLLocation, latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(location.coordinate.latitude, latitude, accuracy: 0.000001, file: file, line: line)
        XCTAssertEqual(location.coordinate.longitude, longitude, accuracy: 0.000001, file: file, line: line)
    }
    
}
