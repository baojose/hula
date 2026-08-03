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

    // MARK: - Camera capture / permission UI must run on main

    func testCustomCameraUIUpdateRunsInlineOnMainThread() {
        var ran = false
        HLCustomCameraViewController.performCameraUIUpdate {
            XCTAssertTrue(Thread.isMainThread)
            ran = true
        }
        XCTAssertTrue(ran)
    }

    func testPictureSelectUIUpdateRunsInlineOnMainThread() {
        var ran = false
        HLPictureSelectViewController.performCameraUIUpdate {
            XCTAssertTrue(Thread.isMainThread)
            ran = true
        }
        XCTAssertTrue(ran)
    }

    func testProductPictureEditUIUpdateRunsInlineOnMainThread() {
        var ran = false
        HLProductPictureEditViewController.performCameraUIUpdate {
            XCTAssertTrue(Thread.isMainThread)
            ran = true
        }
        XCTAssertTrue(ran)
    }

    func testCameraUIUpdateHopsFromBackgroundThread() {
        let expectation = self.expectation(description: "camera UI hops to main")
        DispatchQueue.global(qos: .userInitiated).async {
            HLCustomCameraViewController.performCameraUIUpdate {
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
