//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import Foundation
import CoreLocation
@testable import Hula

class HulaTests: XCTestCase {

    override func setUp() {
        super.setUp()
        resetSharedUser()
    }

    override func tearDown() {
        resetSharedUser()
        super.tearDown()
    }

    func testSocialCredentialConstantsAreSanitizedForPublicSnapshot() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(HulaConstants.linkedinRedirectURL, "https://hula.trading/")
    }

    func testStaticURLsAreWellFormed() {
        XCTAssertNotNil(URL(string: HulaConstants.apiURL))
        XCTAssertNotNil(URL(string: HulaConstants.staticServerURL))
        XCTAssertNotNil(URL(string: HulaConstants.noProductThumb))
        XCTAssertNotNil(URL(string: HulaConstants.transparentImg))
    }

    func testProductPopulateWithDoubleLocationSetsCoordinateAndFiltersEmptyImages() {
        let product = HulaProduct()

        product.populate(with: [
            "location": [37.785834, -122.406417],
            "images": ["hero.jpg", "", "detail.jpg"]
        ] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.785834, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.406417, accuracy: 0.000001)
        XCTAssertEqual(product.arrProductPhotoLink, ["hero.jpg", "detail.jpg"])
    }

    func testProductPopulateAcceptsBridgedNSNumberLocationPayload() {
        let product = HulaProduct()
        let location = NSArray(objects: NSNumber(value: 51.5074), NSNumber(value: -0.1278))

        product.populate(with: ["location": location] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5074, accuracy: 0.000001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.1278, accuracy: 0.000001)
    }

    func testProductPopulateAcceptsMixedNumericLocationPayload() {
        let product = HulaProduct()

        product.populate(with: ["location": [Float(48.8566), Int(2)]] as NSDictionary)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 48.8566, accuracy: 0.0001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 2.0, accuracy: 0.000001)
    }

    func testProductPopulateIgnoresMalformedLocationsAndPreservesExistingCoordinate() {
        let product = HulaProduct()
        product.populate(with: ["location": [10.25, -20.5]] as NSDictionary)

        product.populate(with: ["location": [11.0]] as NSDictionary)
        assertProduct(product, hasLatitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": ["north", "west"]] as NSDictionary)
        assertProduct(product, hasLatitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": [true, false]] as NSDictionary)
        assertProduct(product, hasLatitude: 10.25, longitude: -20.5)

        product.populate(with: ["location": "10.25,-20.5"] as NSDictionary)
        assertProduct(product, hasLatitude: 10.25, longitude: -20.5)
    }

    func testUserLoginRequiresBothUserIdAndToken() {
        let user = HulaUser.sharedInstance

        user.userId = "user-1"
        user.token = ""
        XCTAssertFalse(user.isUserLoggedIn())

        user.userId = ""
        user.token = "token-1"
        XCTAssertFalse(user.isUserLoggedIn())

        user.userId = "user-1"
        user.token = "token-1"
        XCTAssertTrue(user.isUserLoggedIn())
    }

    func testUserPostStringIncludesLocationOnlyWhenCoordinatesAreNonZero() {
        let user = HulaUser.sharedInstance
        user.userEmail = "user@example.com"
        user.userName = "Hula User"
        user.userBio = "Bio"
        user.userNick = "hula"
        user.userPhotoURL = "photo.jpg"
        user.location = CLLocation(latitude: 0, longitude: 0)

        XCTAssertNil(user.getPostString().range(of: "&lat="))
        XCTAssertNil(user.getPostString().range(of: "&lng="))

        user.location = CLLocation(latitude: 34.0522, longitude: -118.2437)
        user.userLocationName = "Los Angeles"

        let postString = user.getPostString()
        XCTAssertNotNil(postString.range(of: "&lat=34.0522"))
        XCTAssertNotNil(postString.range(of: "&lng=-118.2437"))
        XCTAssertNotNil(postString.range(of: "&location_name=Los Angeles"))
    }

    func testUserFeedbackReturnsDashWhenNoRatingsAndPercentageWhenPresent() {
        let user = HulaUser.sharedInstance

        XCTAssertEqual(user.getFeedback(), "-")

        user.feedback_count = 4
        user.feedback_points = 3

        XCTAssertEqual(user.getFeedback(), "75%")
    }

    private func assertProduct(_ product: HulaProduct, hasLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(product.productLocation.coordinate.latitude, latitude, accuracy: 0.000001, file: file, line: line)
        XCTAssertEqual(product.productLocation.coordinate.longitude, longitude, accuracy: 0.000001, file: file, line: line)
    }

    private func resetSharedUser() {
        let user = HulaUser.sharedInstance
        user.logout()
        user.location = CLLocation(latitude: 0, longitude: 0)
        user.userLocationName = ""
    }
}
