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

    // MARK: - Album / profile picker (Aug 7 critical)

    func testPictureSelectPickerInfoRejectsMissingImage() {
        // Video picks (or empty info) have no OriginalImage — must not force-cast.
        XCTAssertNil(HLPictureSelectViewController.imageFromPickerInfo([:]))
        XCTAssertNil(HLPictureSelectViewController.imageFromPickerInfo([
            UIImagePickerControllerMediaType: "public.movie"
        ]))
    }

    func testPictureSelectPickerInfoAcceptsImage() {
        let image = UIImage()
        let extracted = HLPictureSelectViewController.imageFromPickerInfo([
            UIImagePickerControllerOriginalImage: image
        ])
        XCTAssertNotNil(extracted)
    }

    func testCustomCameraPickerInfoRejectsMissingImage() {
        XCTAssertNil(HLCustomCameraViewController.imageFromPickerInfo([:]))
        XCTAssertNil(HLCustomCameraViewController.imageFromPickerInfo([
            UIImagePickerControllerMediaType: "public.movie"
        ]))
    }

    func testCustomCameraPickerInfoAcceptsImage() {
        let image = UIImage()
        let extracted = HLCustomCameraViewController.imageFromPickerInfo([
            UIImagePickerControllerOriginalImage: image
        ])
        XCTAssertNotNil(extracted)
    }

    // MARK: - Seller profile pending-offer gate (Aug 7 critical)

    func testShouldOfferStartTradeWhenIdle() {
        XCTAssertTrue(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: false,
            pendingInboundOffer: false
        ))
    }

    func testShouldNotOfferStartTradeWhenAlreadyTrading() {
        XCTAssertFalse(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: true,
            pendingInboundOffer: false
        ))
    }

    func testShouldNotOfferStartTradeWhenPendingInboundOffer() {
        // Options → "Trade with this user" must not POST a second room while Accept/Decline is showing.
        XCTAssertFalse(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: false,
            pendingInboundOffer: true
        ))
    }

    func testShouldNotOfferStartTradeWhenBothTradingAndPending() {
        XCTAssertFalse(HLDataManager.shouldOfferStartTradeAction(
            tradingWith: true,
            pendingInboundOffer: true
        ))
    }
}
