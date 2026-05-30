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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPlaceholderConfigValuesAreRejected() {
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue(nil))
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue(""))
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue("   "))
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue("YOUR_LINKEDIN_CLIENT_ID"))
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue("REPLACE_ME_LINKEDIN_CLIENT_SECRET"))
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue("$(LINKEDIN_CLIENT_ID)"))
        XCTAssertFalse(HulaConstants.isConfiguredInfoValue("placeholder-linkedin-state"))
        XCTAssertTrue(HulaConstants.isConfiguredInfoValue("linkedin-client-id"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
