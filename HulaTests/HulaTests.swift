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

    // MARK: - Feedback history score bridging

    func testFeedbackScorePercentAcceptsIntegerStarValues() {
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: 5), "100%")
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: 4), "80%")
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: 1), "20%")
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: NSNumber(value: 3)), "60%")
    }

    func testFeedbackScorePercentAcceptsFloatingStarValues() {
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: 4.5 as Double), "90%")
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: Float(2)), "40%")
        XCTAssertEqual(HLFeedbackHistoryViewController.feedbackScorePercent(from: CGFloat(5)), "100%")
    }

    func testFeedbackScorePercentRejectsBoolAndMissing() {
        XCTAssertNil(HLFeedbackHistoryViewController.feedbackScorePercent(from: true))
        XCTAssertNil(HLFeedbackHistoryViewController.feedbackScorePercent(from: false))
        XCTAssertNil(HLFeedbackHistoryViewController.feedbackScorePercent(from: nil))
        XCTAssertNil(HLFeedbackHistoryViewController.feedbackScorePercent(from: "5"))
    }

    // MARK: - Product create image attach race

    func testShouldAttachUploadedImagesWaitsForProductId() {
        XCTAssertFalse(HLMyProductsViewController.shouldAttachUploadedImages(
            productId: "",
            imagesToUpload: 2,
            imagesAlreadyUploaded: 2
        ))
        XCTAssertFalse(HLMyProductsViewController.shouldAttachUploadedImages(
            productId: nil,
            imagesToUpload: 1,
            imagesAlreadyUploaded: 1
        ))
        XCTAssertTrue(HLMyProductsViewController.shouldAttachUploadedImages(
            productId: "abc123",
            imagesToUpload: 2,
            imagesAlreadyUploaded: 2
        ))
    }

    func testShouldAttachUploadedImagesWaitsForAllUploads() {
        XCTAssertFalse(HLMyProductsViewController.shouldAttachUploadedImages(
            productId: "abc123",
            imagesToUpload: 3,
            imagesAlreadyUploaded: 1
        ))
        XCTAssertTrue(HLMyProductsViewController.shouldAttachUploadedImages(
            productId: "abc123",
            imagesToUpload: 0,
            imagesAlreadyUploaded: 0
        ))
    }

    func testUploadSlotIndexAcceptsStringAndNumericJSON() {
        XCTAssertEqual(HLMyProductsViewController.uploadSlotIndex(from: "0"), 0)
        XCTAssertEqual(HLMyProductsViewController.uploadSlotIndex(from: "2"), 2)
        XCTAssertEqual(HLMyProductsViewController.uploadSlotIndex(from: 1), 1)
        XCTAssertEqual(HLMyProductsViewController.uploadSlotIndex(from: NSNumber(value: 3)), 3)
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: "4"))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: -1))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: true))
        XCTAssertNil(HLMyProductsViewController.uploadSlotIndex(from: nil))
    }

    // MARK: - Chat message validation (no silent truncation)

    func testValidatedChatMessageRejectsOverLimitWithoutTruncating() {
        let long = String(repeating: "a", count: ChatViewController.maxChatMessageLength + 1)
        XCTAssertNil(ChatViewController.validatedChatMessage(long))
    }

    func testValidatedChatMessageAcceptsBoundaryAndTrims() {
        let exact = String(repeating: "b", count: ChatViewController.maxChatMessageLength)
        XCTAssertEqual(ChatViewController.validatedChatMessage(exact), exact)
        XCTAssertEqual(ChatViewController.validatedChatMessage("  hello  "), "hello")
        XCTAssertNil(ChatViewController.validatedChatMessage("   "))
        XCTAssertNil(ChatViewController.validatedChatMessage(nil))
    }
}
