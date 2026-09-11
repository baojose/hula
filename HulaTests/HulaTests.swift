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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSignupNickCheckIgnoresTapsWhileInFlight() {
        XCTAssertTrue(SignupNickCheckPolicy.canStartNickCheck(currentStep: 0, nickCheckInFlight: false))
        XCTAssertFalse(SignupNickCheckPolicy.canStartNickCheck(currentStep: 0, nickCheckInFlight: true))
        XCTAssertFalse(SignupNickCheckPolicy.canStartNickCheck(currentStep: 1, nickCheckInFlight: false))
    }

    func testSignupNickCheckAppliesOnlyLatestStepZeroResponse() {
        XCTAssertTrue(SignupNickCheckPolicy.shouldApplyNickCheckResponse(currentStep: 0, requestId: 2, expectedRequestId: 2))
        XCTAssertFalse(SignupNickCheckPolicy.shouldApplyNickCheckResponse(currentStep: 0, requestId: 1, expectedRequestId: 2))
        XCTAssertFalse(SignupNickCheckPolicy.shouldApplyNickCheckResponse(currentStep: 1, requestId: 2, expectedRequestId: 2))
    }

    func testSignupNickCheckLandsOnEmailStepNotIncrement() {
        XCTAssertEqual(SignupNickCheckPolicy.stepAfterNickAvailable(), 1)
        XCTAssertTrue(SignupNickCheckPolicy.isValidDisplayStep(0))
        XCTAssertTrue(SignupNickCheckPolicy.isValidDisplayStep(2))
        XCTAssertFalse(SignupNickCheckPolicy.isValidDisplayStep(3))
        XCTAssertFalse(SignupNickCheckPolicy.isValidDisplayStep(-1))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
