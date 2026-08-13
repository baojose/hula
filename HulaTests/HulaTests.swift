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

    func testBlockingLoadAlwaysHidesSpinnerWhenRequestFinishes() {
        let transportFailure = BlockingNetworkLoadUI.outcome(ok: false, payloadUsable: false)
        XCTAssertTrue(transportFailure.hideSpinner)
        XCTAssertFalse(transportFailure.applyPayload)
        XCTAssertFalse(transportFailure.treatAsExpiredSession)

        let unexpectedJSON = BlockingNetworkLoadUI.outcome(ok: true, payloadUsable: false)
        XCTAssertTrue(unexpectedJSON.hideSpinner)
        XCTAssertFalse(unexpectedJSON.applyPayload)
        XCTAssertTrue(unexpectedJSON.treatAsExpiredSession)

        let success = BlockingNetworkLoadUI.outcome(ok: true, payloadUsable: true)
        XCTAssertTrue(success.hideSpinner)
        XCTAssertTrue(success.applyPayload)
        XCTAssertFalse(success.treatAsExpiredSession)
    }

    func testStartTradeOverlayWaitsForSuccessfulPost() {
        XCTAssertFalse(StartTradeUIPolicy.shouldExpandOverlay(postCompleted: false, postSucceeded: false))
        XCTAssertFalse(StartTradeUIPolicy.shouldExpandOverlay(postCompleted: false, postSucceeded: true))
        XCTAssertFalse(StartTradeUIPolicy.shouldExpandOverlay(postCompleted: true, postSucceeded: false))
        XCTAssertTrue(StartTradeUIPolicy.shouldExpandOverlay(postCompleted: true, postSucceeded: true))

        XCTAssertFalse(StartTradeUIPolicy.shouldOpenSwapView(postSucceeded: false))
        XCTAssertTrue(StartTradeUIPolicy.shouldOpenSwapView(postSucceeded: true))
    }

    func testVideoProofUsesUniqueFileAndSkipsFailedWrites() {
        let name = VideoProofUploadPolicy.fileName(productId: "abc/def", tradeId: "trade:1")
        XCTAssertEqual(name, "videoproof_abc_def_trade_1.mov")
        XCTAssertFalse(name.contains("testvideo.mov"))
        XCTAssertFalse(name.contains("/"))
        XCTAssertFalse(name.contains(":"))

        XCTAssertFalse(VideoProofUploadPolicy.shouldUpload(dataAvailable: false, writeSucceeded: false))
        XCTAssertFalse(VideoProofUploadPolicy.shouldUpload(dataAvailable: true, writeSucceeded: false))
        XCTAssertFalse(VideoProofUploadPolicy.shouldUpload(dataAvailable: false, writeSucceeded: true))
        XCTAssertTrue(VideoProofUploadPolicy.shouldUpload(dataAvailable: true, writeSucceeded: true))
    }

    func testCompleteProfileHidesConditionOnlyForServiceCategory() {
        XCTAssertTrue(CompleteProductProfilePolicy.shouldHideConditionGroup(categoryId: CompleteProductProfilePolicy.serviceCategoryId))
        XCTAssertFalse(CompleteProductProfilePolicy.shouldHideConditionGroup(categoryId: nil))
        XCTAssertFalse(CompleteProductProfilePolicy.shouldHideConditionGroup(categoryId: ""))
        XCTAssertFalse(CompleteProductProfilePolicy.shouldHideConditionGroup(categoryId: "other"))
    }
}
