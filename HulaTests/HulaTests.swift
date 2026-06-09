//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import CoreLocation
import LinkedinSwift
@testable import Hula

class HulaTests: XCTestCase {

    func testPublicSnapshotKeepsThirdPartyCredentialPlaceholdersEmpty() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "")
    }

    func testLinkedinConfigurationUsesSanitizedConstants() {
        let configuration = HLProfileViewController.linkedinConfiguration()

        XCTAssertEqual(configuration.clientId, HulaConstants.linkedinClientId)
        XCTAssertEqual(configuration.clientSecret, HulaConstants.linkedinClientSecret)
        XCTAssertEqual(configuration.state, HulaConstants.linkedinState)
        XCTAssertEqual(configuration.redirectUrl, HulaConstants.linkedinRedirectUrl)
        let permissions = configuration.permissions as? [String]
        XCTAssertNotNil(permissions)
        XCTAssertEqual(permissions!, HulaConstants.linkedinPermissions)
    }

    func testProductLocationParsingPreservesDoublePrecision() {
        let product = HulaProduct()
        let latitude = 12.3456789012345
        let longitude = -98.7654321098765

        product.populate(with: ["location": [latitude, longitude]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000000001)
    }

    func testProductLocationParsingAcceptsNSArrayNumberPayloads() {
        let product = HulaProduct()
        let location = NSArray(objects: NSNumber(value: 19.432608), NSNumber(value: -99.133209))

        product.populate(with: ["location": location] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 19.432608, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -99.133209, accuracy: 0.000000001)
    }

    func testProductLocationParsingAcceptsMixedNumericPayloads() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(40.7128), -74]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 40.7128, accuracy: 0.00001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -74.0, accuracy: 0.000000001)
    }

    func testMalformedProductLocationPayloadsPreserveExistingLocation() {
        let product = HulaProduct()
        product.populate(with: ["location": [33.8121, -117.9190]] as NSDictionary)

        product.populate(with: ["location": [99.0]] as NSDictionary)
        assertProduct(product, stillHasLatitude: 33.8121, longitude: -117.9190)

        product.populate(with: ["location": ["north", "west"]] as NSDictionary)
        assertProduct(product, stillHasLatitude: 33.8121, longitude: -117.9190)

        product.populate(with: ["location": [true, false]] as NSDictionary)
        assertProduct(product, stillHasLatitude: 33.8121, longitude: -117.9190)
    }

    private func assertProduct(_ product: HulaProduct, stillHasLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000000001)
    }
}
