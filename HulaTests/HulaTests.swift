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
    }

    override func tearDown() {
        super.tearDown()
    }

    func testProductPostStringUsesProductLocationNotUserGPS() {
        let product = HulaProduct()
        product.productId = "prod-1"
        product.productName = "Lamp"
        product.productDescription = "Desk lamp"
        product.productCondition = "good"
        product.productCategory = "Home"
        product.productCategoryId = "cat-1"
        product.productImage = "https://example.com/lamp.jpg"
        product.productOwner = "owner-1"
        product.arrProductPhotoLink = ["https://example.com/lamp.jpg"]
        product.productLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)

        // Simulate user being somewhere else (or GPS still at 0,0).
        let previousUserLocation = HulaUser.sharedInstance.location
        HulaUser.sharedInstance.location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        defer { HulaUser.sharedInstance.location = previousUserLocation }

        let body = product.getPostString()
        XCTAssertTrue(body.contains("lat=40.7128"), "Edit PUT must keep product lat; got \(body)")
        XCTAssertTrue(body.contains("lng=-74.006"), "Edit PUT must keep product lng; got \(body)")
        XCTAssertFalse(body.contains("lat=37.7749"), "Must not overwrite with user GPS; got \(body)")
        XCTAssertFalse(body.contains("lng=-122.4194"), "Must not overwrite with user GPS; got \(body)")
    }

    func testProductPostStringOmitsZeroCoordinates() {
        let product = HulaProduct()
        product.productName = "Untitled"
        product.productDescription = ""
        product.productCondition = ""
        product.productCategory = ""
        product.productCategoryId = ""
        product.productImage = ""
        product.productOwner = ""
        product.arrProductPhotoLink = []
        product.productLocation = CLLocation(latitude: 0, longitude: 0)

        let previousUserLocation = HulaUser.sharedInstance.location
        HulaUser.sharedInstance.location = CLLocation(latitude: 51.5074, longitude: -0.1278)
        defer { HulaUser.sharedInstance.location = previousUserLocation }

        let body = product.getPostString()
        XCTAssertFalse(body.contains("&lat="), "Unset product location must not send lat; got \(body)")
        XCTAssertFalse(body.contains("&lng="), "Unset product location must not send lng; got \(body)")
    }

    func testClearingLastPhotoEmptiesFeaturedImageURL() {
        // Mirrors HLEditProductMainViewController.redrawProductImages featured-image sync.
        let product = HulaProduct()
        product.productImage = "https://example.com/old.jpg"
        product.arrProductPhotoLink = []

        if product.arrProductPhotoLink.count > 0 && product.arrProductPhotoLink[0].count > 0 {
            product.productImage = product.arrProductPhotoLink[0]
        } else {
            product.productImage = ""
        }

        XCTAssertEqual(product.productImage, "")
        let body = product.getPostString()
        XCTAssertTrue(body.contains("image_url="), body)
        XCTAssertFalse(body.contains("image_url=https://example.com/old.jpg"), "Deleted photo must not remain as featured image_url; got \(body)")
    }
}
