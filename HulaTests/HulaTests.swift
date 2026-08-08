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

    // MARK: - Complete-profile Done inventory index (Aug 8 critical)

    func testIndexOfProductFindsNonLastIncompleteProduct() {
        let a = HulaProduct(id: "a", name: "A", image: "")
        let b = HulaProduct(id: "b", name: "Untitled product", image: "")
        let c = HulaProduct(id: "c", name: "C", image: "")
        let products = [a, b, c]
        XCTAssertEqual(HLMyProductsViewController.indexOfProduct(withId: "b", in: products), 1)
        XCTAssertNotEqual(HLMyProductsViewController.indexOfProduct(withId: "b", in: products), products.count - 1)
    }

    func testIndexOfProductMissingIdReturnsNil() {
        let a = HulaProduct(id: "a", name: "A", image: "")
        XCTAssertNil(HLMyProductsViewController.indexOfProduct(withId: "missing", in: [a]))
        XCTAssertNil(HLMyProductsViewController.indexOfProduct(withId: "", in: [a]))
    }

    // MARK: - My Products payload / false session expiry

    func testProductsListPayloadAcceptsArray() {
        XCTAssertTrue(HLMyProductsViewController.isProductsListPayload([]))
        XCTAssertTrue(HLMyProductsViewController.isProductsListPayload([["_id": "1"]]))
    }

    func testProductsListPayloadRejectsErrorObject() {
        // httpGet treats any JSON as ok=true; error objects must not force re-login.
        XCTAssertFalse(HLMyProductsViewController.isProductsListPayload(["message": "Unauthorized"]))
        XCTAssertFalse(HLMyProductsViewController.isProductsListPayload(nil))
        XCTAssertFalse(HLMyProductsViewController.isProductsListPayload("bad"))
    }

    // MARK: - Home category num_products soft parse

    func testCategoryProductCountSoftParsesMissingAndNumberTypes() {
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: [:]), 0)
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: ["num_products": 12]), 12)
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: ["num_products": NSNumber(value: 7)]), 7)
        XCTAssertEqual(HLHomeViewController.categoryProductCount(from: ["num_products": 3.0]), 3)
    }

    // MARK: - Shared image URL loader

    func testResolvedImageURLFallsBackForMalformedString() {
        let malformed = "https://hula.trading/files/user/photo with spaces.jpg"
        let resolved = UIImageView.resolvedImageURL(from: malformed)
        XCTAssertNotNil(resolved)
        XCTAssertEqual(resolved?.absoluteString, HulaConstants.noProductThumb)
    }

    func testResolvedImageURLAcceptsValidAndEmpty() {
        let valid = UIImageView.resolvedImageURL(from: "https://hula.trading/files/user/ok.jpg")
        XCTAssertEqual(valid?.absoluteString, "https://hula.trading/files/user/ok.jpg")
        let empty = UIImageView.resolvedImageURL(from: "")
        XCTAssertEqual(empty?.absoluteString, HulaConstants.noProductThumb)
    }
}
