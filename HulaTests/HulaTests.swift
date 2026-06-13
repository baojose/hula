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

    func testLinkedinConfigurationRejectsPlaceholders() {
        let infoDictionary: [String: Any] = [
            LinkedinAppConfiguration.clientIdKey: "YOUR_LINKEDIN_APP_ID",
            LinkedinAppConfiguration.clientSecretKey: "REPLACE_ME_LINKEDIN_CLIENT_SECRET",
            LinkedinAppConfiguration.stateKey: "REPLACE_ME_LINKEDIN_STATE",
            LinkedinAppConfiguration.redirectUrlKey: "https://hula.trading/"
        ]

        XCTAssertNil(LinkedinAppConfiguration.fromInfoDictionary(infoDictionary))
    }

    func testLinkedinConfigurationAcceptsConfiguredValues() {
        let infoDictionary: [String: Any] = [
            LinkedinAppConfiguration.clientIdKey: "configured-client-id",
            LinkedinAppConfiguration.clientSecretKey: "configured-client-secret",
            LinkedinAppConfiguration.stateKey: "configured-state",
            LinkedinAppConfiguration.redirectUrlKey: "https://hula.trading/"
        ]

        let configuration = LinkedinAppConfiguration.fromInfoDictionary(infoDictionary)

        XCTAssertEqual(configuration?.clientId, "configured-client-id")
        XCTAssertEqual(configuration?.clientSecret, "configured-client-secret")
        XCTAssertEqual(configuration?.state, "configured-state")
        XCTAssertEqual(configuration?.redirectUrl, "https://hula.trading/")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
