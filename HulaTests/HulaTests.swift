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

    // MARK: - Onboarding tip index safety (CommonUtils.removeEasyTips)

    func testTipIndexInvalidWhenFinishedTutorial() {
        // showNextTip sets currentTip = -1 after the last tip while the dim
        // overlay can still receive taps for ~0.5s.
        XCTAssertFalse(CommonUtils.isValidTipIndex(-1, count: 3))
        XCTAssertFalse(CommonUtils.isValidTipIndex(-1, count: 0))
    }

    func testTipIndexValidOnlyInsideBounds() {
        XCTAssertTrue(CommonUtils.isValidTipIndex(0, count: 1))
        XCTAssertTrue(CommonUtils.isValidTipIndex(2, count: 3))
        XCTAssertFalse(CommonUtils.isValidTipIndex(3, count: 3))
        XCTAssertFalse(CommonUtils.isValidTipIndex(0, count: 0))
    }

    // MARK: - Profile avatar upload JSON (HLPictureSelectViewController)

    func testProfileImageURLFromPathIgnoresMissingPosition() {
        // Former code required position as String; API often returns a number,
        // which left the camera UI stuck after stopSession().
        let json: [String: Any] = ["path": "uploads/avatar.jpg", "position": 10]
        let url = HLPictureSelectViewController.profileImageURL(fromUploadJSON: json)
        XCTAssertEqual(url, HulaConstants.staticServerURL + "uploads/avatar.jpg")
    }

    func testProfileImageURLFromPathWithStringPosition() {
        let json: [String: Any] = ["path": "uploads/avatar.jpg", "position": "10"]
        let url = HLPictureSelectViewController.profileImageURL(fromUploadJSON: json)
        XCTAssertEqual(url, HulaConstants.staticServerURL + "uploads/avatar.jpg")
    }

    func testProfileImageURLNilWithoutPath() {
        XCTAssertNil(HLPictureSelectViewController.profileImageURL(fromUploadJSON: ["position": 10]))
        XCTAssertNil(HLPictureSelectViewController.profileImageURL(fromUploadJSON: nil))
        XCTAssertNil(HLPictureSelectViewController.profileImageURL(fromUploadJSON: ["path": ""]))
    }
}
