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

    // MARK: - Form encoding (product create/update)

    func testFormEncodedValueEscapesFormDelimitersAndPlus() {
        let encoded = CommonUtils.formEncodedValue("Toys & Games + more=yes")
        XCTAssertFalse(encoded.contains("&"), "raw & must not remain in a form field value")
        XCTAssertFalse(encoded.contains("="), "raw = must not remain in a form field value")
        XCTAssertFalse(encoded.contains("+"), "raw + must be encoded so it is not decoded as a space")
        XCTAssertTrue(encoded.contains("%26"))
        XCTAssertTrue(encoded.contains("%3D") || encoded.contains("%3d"))
        XCTAssertTrue(encoded.contains("%2B") || encoded.contains("%2b"))
    }

    func testProductFormPostStringDoesNotSplitOnAmpersandInTitle() {
        let body = CommonUtils.productFormPostString(
            title: "Toys & Games",
            description: "Fun=stuff",
            condition: "used",
            categoryId: "cat-1",
            imagesCSV: "a.jpg,b.jpg",
            latitude: 1.5,
            longitude: -2.5
        )

        // A naive split on '&' must still yield exactly the expected keys.
        let pairs = body.components(separatedBy: "&")
        XCTAssertEqual(pairs.count, 7)
        XCTAssertTrue(pairs[0].hasPrefix("title="))
        XCTAssertTrue(pairs[1].hasPrefix("description="))
        XCTAssertTrue(pairs[2].hasPrefix("condition="))
        XCTAssertTrue(pairs[3].hasPrefix("category_id="))
        XCTAssertTrue(pairs[4].hasPrefix("images="))
        XCTAssertEqual(pairs[5], "lat=1.5")
        XCTAssertEqual(pairs[6], "lng=-2.5")

        // urlHostAllowed would leave the title ampersand unescaped and create a bogus field.
        XCTAssertFalse(body.contains("title=Toys "))
        XCTAssertTrue(body.contains("%26"))
    }

    // MARK: - Complete product profile title wipe

    func testResolvedProductFieldsKeepsExistingTitleWhenFieldBlank() {
        let resolved = HLCompleteProductProfileViewController.resolvedProductFields(
            titleField: "",
            descriptionField: "Still a great item",
            existingTitle: "Untitled product",
            existingDescription: ""
        )
        XCTAssertEqual(resolved.title, "Untitled product")
        XCTAssertEqual(resolved.description, "Still a great item")
    }

    func testResolvedProductFieldsUsesTypedTitle() {
        let resolved = HLCompleteProductProfileViewController.resolvedProductFields(
            titleField: "  Bike  ",
            descriptionField: "  lightly used  ",
            existingTitle: "Untitled product",
            existingDescription: "old"
        )
        XCTAssertEqual(resolved.title, "Bike")
        XCTAssertEqual(resolved.description, "lightly used")
    }

    func testResolvedProductFieldsFallsBackToUntitledWhenNoTitleAnywhere() {
        let resolved = HLCompleteProductProfileViewController.resolvedProductFields(
            titleField: nil,
            descriptionField: "desc",
            existingTitle: nil,
            existingDescription: nil
        )
        XCTAssertEqual(resolved.title, NSLocalizedString("Untitled product", comment: ""))
        XCTAssertEqual(resolved.description, "desc")
    }

    // MARK: - Trade chat segue configuration

    func testChatConfigurationSetsTradeIdWhenChatMissing() {
        let config = HLSwappViewController.chatConfiguration(from: [
            "_id": "trade-abc"
        ] as NSDictionary)
        XCTAssertEqual(config.tradeId, "trade-abc")
        XCTAssertEqual(config.chat.count, 0)
    }

    func testChatConfigurationSetsTradeIdWhenChatNullTyped() {
        let config = HLSwappViewController.chatConfiguration(from: [
            "_id": "trade-xyz",
            "chat": NSNull()
        ] as NSDictionary)
        XCTAssertEqual(config.tradeId, "trade-xyz")
        XCTAssertEqual(config.chat.count, 0)
    }

    func testChatConfigurationPreservesExistingMessages() {
        let message: NSDictionary = ["user_id": "u1", "message": "hi", "date": "2026-01-01T00:00:00.000Z"]
        let config = HLSwappViewController.chatConfiguration(from: [
            "_id": "trade-1",
            "chat": [message]
        ] as NSDictionary)
        XCTAssertEqual(config.tradeId, "trade-1")
        XCTAssertEqual(config.chat.count, 1)
        XCTAssertEqual(config.chat[0].object(forKey: "message") as? String, "hi")
    }
}
