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
    
    func testProductPopulateKeepsDoublePrecisionLocation() {
        let product = HulaProduct()
        
        product.populate(with: ["location": [37.7749295, -122.4194155]] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.7749295, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.4194155, accuracy: 0.0000001)
    }
    
    func testProductPopulateAcceptsBridgedNumberLocation() {
        let product = HulaProduct()
        let location = NSArray(objects: NSNumber(value: 51.5007292), NSNumber(value: -0.1246254))
        
        product.populate(with: ["location": location] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5007292, accuracy: 0.0000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.1246254, accuracy: 0.0000001)
    }
    
    func testProductPopulateAcceptsMixedNumericLocation() {
        let product = HulaProduct()
        let location: [Any] = [Float(12.25), 44]
        
        product.populate(with: ["location": location] as NSDictionary)
        
        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.25, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 44.0, accuracy: 0.000001)
    }
    
    func testProductPopulatePreservesLocationForMalformedPayloads() {
        let product = HulaProduct()
        product.productLocation = CLLocation(latitude: 10.5, longitude: -20.25)
        
        let malformedLocations: [Any] = [
            [12.0],
            ["north", "west"],
            [true, false],
            true,
            "not-array"
        ]
        
        for location in malformedLocations {
            product.populate(with: ["location": location] as NSDictionary)
            XCTAssertEqual(product.productLocation.coordinate.latitude, 10.5, accuracy: 0.000001)
            XCTAssertEqual(product.productLocation.coordinate.longitude, -20.25, accuracy: 0.000001)
        }
    }
    
    func testSocialCredentialConstantsUsePublicPlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
    }
    
    func testLinkedInConfigurationKeepsExpectedPublicShape() {
        XCTAssertEqual(HulaConstants.linkedinState, "DLKDJF46ikMMZADfdfds")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectUrl, "https://hula.trading/")
    }
    
}
