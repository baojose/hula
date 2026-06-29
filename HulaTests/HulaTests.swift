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
        let payload: NSDictionary = [
            "location": [12.345678901, -45.678901234]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 12.345678901, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -45.678901234, accuracy: 0.000000001)
    }

    func testProductPopulateAcceptsBridgedAndMixedNumericLocations() {
        let bridgedProduct = HulaProduct()
        let bridgedLocation = NSArray(objects: NSNumber(value: 51.5), NSNumber(value: -0.125))
        bridgedProduct.populate(with: ["location": bridgedLocation] as NSDictionary)

        XCTAssertEqual(bridgedProduct.productLocation.coordinate.latitude, 51.5, accuracy: 0.000000001)
        XCTAssertEqual(bridgedProduct.productLocation.coordinate.longitude, -0.125, accuracy: 0.000000001)

        let mixedProduct = HulaProduct()
        mixedProduct.populate(with: ["location": [Float(40.75), -74] as [Any]] as NSDictionary)

        XCTAssertEqual(mixedProduct.productLocation.coordinate.latitude, 40.75, accuracy: 0.000001)
        XCTAssertEqual(mixedProduct.productLocation.coordinate.longitude, -74.0, accuracy: 0.000001)
    }

    func testProductPopulatePreservesExistingLocationForMalformedPayloads() {
        let malformedLocations: [Any] = [
            [10.0] as [Any],
            ["north", -3.0] as [Any],
            [true, false] as [Any],
            "not-an-array"
        ]

        for malformedLocation in malformedLocations {
            let product = HulaProduct()
            product.productLocation = CLLocation(latitude: 1.25, longitude: 2.5)

            product.populate(with: ["location": malformedLocation] as NSDictionary)

            XCTAssertEqual(product.productLocation.coordinate.latitude, 1.25, accuracy: 0.000000001)
            XCTAssertEqual(product.productLocation.coordinate.longitude, 2.5, accuracy: 0.000000001)
        }
    }

    func testUserPopulateAcceptsPreciseAndBridgedLocations() {
        let preciseUser = HulaUser()
        preciseUser.populate(with: ["location": [60.123456789, 24.987654321]] as NSDictionary)

        XCTAssertEqual(preciseUser.location.coordinate.latitude, 60.123456789, accuracy: 0.000000001)
        XCTAssertEqual(preciseUser.location.coordinate.longitude, 24.987654321, accuracy: 0.000000001)

        let bridgedUser = HulaUser()
        let bridgedLocation = NSArray(objects: NSNumber(value: -33.875), NSNumber(value: 151.25))
        bridgedUser.populate(with: ["location": bridgedLocation] as NSDictionary)

        XCTAssertEqual(bridgedUser.location.coordinate.latitude, -33.875, accuracy: 0.000000001)
        XCTAssertEqual(bridgedUser.location.coordinate.longitude, 151.25, accuracy: 0.000000001)
    }

    func testUserPopulatePreservesExistingLocationForMalformedPayloads() {
        let malformedLocations: [Any] = [
            [] as [Any],
            [44.0, "east"] as [Any],
            [false, true] as [Any],
            "not-an-array"
        ]

        for malformedLocation in malformedLocations {
            let user = HulaUser()
            user.location = CLLocation(latitude: -1.5, longitude: 99.75)

            user.populate(with: ["location": malformedLocation] as NSDictionary)

            XCTAssertEqual(user.location.coordinate.latitude, -1.5, accuracy: 0.000000001)
            XCTAssertEqual(user.location.coordinate.longitude, 99.75, accuracy: 0.000000001)
        }
    }

    func testPublicSnapshotKeepsSocialCredentialsAsPlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "DLKDJF46ikMMZADfdfds")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectUrl, "https://hula.trading/")
    }
}
