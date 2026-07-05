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

    func testLinkedinConfigurationRejectsPublicPlaceholders() {
        XCTAssertFalse(HLProfileViewController.isUsableLinkedinConfigurationValue(nil))
        XCTAssertFalse(HLProfileViewController.isUsableLinkedinConfigurationValue(""))
        XCTAssertFalse(HLProfileViewController.isUsableLinkedinConfigurationValue("YOUR_LINKEDIN_APP_SECRET"))
        XCTAssertFalse(HLProfileViewController.isUsableLinkedinConfigurationValue("REPLACE_ME_LINKEDIN_APP_SECRET"))
        XCTAssertFalse(HLProfileViewController.isUsableLinkedinConfigurationValue("GENERATE_LINKEDIN_OAUTH_STATE"))
        XCTAssertFalse(HLProfileViewController.isUsableLinkedinConfigurationValue("$(LI_APP_SECRET)"))
    }

    func testLinkedinConfigurationAcceptsPrivateValues() {
        XCTAssertTrue(HLProfileViewController.isUsableLinkedinConfigurationValue("real-linkedin-client-id"))
        XCTAssertTrue(HLProfileViewController.isUsableLinkedinConfigurationValue("  real-linkedin-client-secret  "))
        XCTAssertTrue(HLProfileViewController.isUsableLinkedinConfigurationValue("https://hula.trading/"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
