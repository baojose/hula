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
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCreateCallbackDoesNotRetargetReplacementProduct() {
        let original = HulaProduct()
        let replacement = HulaProduct()
        original.productName = "Camera"
        replacement.productName = "Bike"

        ProductCreateSession.applyCreatedProductId("id-original", to: original)

        XCTAssertEqual(original.productId, "id-original")
        XCTAssertEqual(replacement.productId, "")
        XCTAssertEqual(replacement.productName, "Bike")
    }

    func testCreatePhotoCallbackWritesCapturedProductOnly() {
        let original = HulaProduct()
        let replacement = HulaProduct()
        original.arrProductPhotoLink = ProductCreateSession.preparedPhotoSlots()
        replacement.arrProductPhotoLink = ProductCreateSession.preparedPhotoSlots()

        let applied = ProductCreateSession.applyPhotoLink("https://hula.trading/a.jpg", at: 0, to: original)

        XCTAssertTrue(applied)
        XCTAssertEqual(original.arrProductPhotoLink[0], "https://hula.trading/a.jpg")
        XCTAssertEqual(original.productImage, "https://hula.trading/a.jpg")
        XCTAssertEqual(replacement.arrProductPhotoLink[0], "")
        XCTAssertEqual(replacement.productImage, "")
    }

    func testCreatePhotoCallbackRejectsOutOfRangeSlot() {
        let product = HulaProduct()
        product.arrProductPhotoLink = ProductCreateSession.preparedPhotoSlots()

        XCTAssertFalse(ProductCreateSession.applyPhotoLink("https://hula.trading/x.jpg", at: -1, to: product))
        XCTAssertFalse(ProductCreateSession.applyPhotoLink("https://hula.trading/x.jpg", at: 4, to: product))
        XCTAssertEqual(product.arrProductPhotoLink[0], "")
        XCTAssertEqual(product.productImage, "")
    }

    func testCompleteProfilePresentationRequiresSameTarget() {
        let creating = HulaProduct()
        let other = HulaProduct()

        XCTAssertTrue(ProductCreateSession.shouldPresentCompleteProfile(captured: creating, current: creating))
        XCTAssertFalse(ProductCreateSession.shouldPresentCompleteProfile(captured: creating, current: other))
    }

    func testFirstLocalPhotoMissingDoesNotForceUnwrap() {
        let empty = HulaProduct()
        XCTAssertNil(ProductCreateSession.firstLocalPhoto(on: empty))

        let withPhoto = HulaProduct()
        withPhoto.arrProductPhotos.add(UIImage())
        XCTAssertNotNil(ProductCreateSession.firstLocalPhoto(on: withPhoto))
    }

    func testEmptyProductIdIsNotApplied() {
        let product = HulaProduct()
        product.productId = "keep-me"
        ProductCreateSession.applyCreatedProductId("", to: product)
        XCTAssertEqual(product.productId, "keep-me")
    }
}
