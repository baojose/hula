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
        XCTAssertFalse(HulaConstants.isConfiguredCredential(""))
        XCTAssertFalse(HulaConstants.isConfiguredCredential("YOUR_LINKEDIN_APP_ID"))
        XCTAssertFalse(HulaConstants.isConfiguredCredential("REPLACE_ME_LINKEDIN_CLIENT_SECRET"))
        XCTAssertFalse(HulaConstants.isConfiguredCredential("$(LINKEDIN_CLIENT_SECRET)"))
        XCTAssertTrue(HulaConstants.isConfiguredCredential("real-linkedin-value"))
    }

    func testLinkedinConfigurationRequiresEveryCredential() {
        XCTAssertFalse(HulaConstants.isLinkedinConfigurationValid(clientId: "real-client-id",
                                                                  clientSecret: "REPLACE_ME_LINKEDIN_CLIENT_SECRET",
                                                                  state: "real-state",
                                                                  redirectURL: "https://hula.trading/"))

        XCTAssertTrue(HulaConstants.isLinkedinConfigurationValid(clientId: "real-client-id",
                                                                 clientSecret: "real-client-secret",
                                                                 state: "real-state",
                                                                 redirectURL: "https://hula.trading/"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
