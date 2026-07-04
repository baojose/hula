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
        let placeholderInfo = [
            "LIAppId": "YOUR_LINKEDIN_APP_ID",
            "LIAppSecret": "YOUR_LINKEDIN_APP_SECRET",
            "LIState": "YOUR_LINKEDIN_STATE",
            "LIRedirectURL": "YOUR_LINKEDIN_REDIRECT_URL"
        ]

        XCTAssertNil(HLProfileViewController.linkedinConfiguration(from: placeholderInfo))
    }

    func testLinkedinConfigurationUsesConfiguredValues() {
        let configuredInfo = [
            "LIAppId": "linkedin-app-id",
            "LIAppSecret": "linkedin-app-secret",
            "LIState": "random-state-value",
            "LIRedirectURL": "https://example.com/linkedin"
        ]

        let configuration = HLProfileViewController.linkedinConfiguration(from: configuredInfo)

        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration?.clientId, "linkedin-app-id")
        XCTAssertEqual(configuration?.clientSecret, "linkedin-app-secret")
        XCTAssertEqual(configuration?.state, "random-state-value")
        XCTAssertEqual(configuration?.redirectUrl, "https://example.com/linkedin")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
