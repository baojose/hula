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
        let info: [String: Any] = [
            "LIAppId": "YOUR_LINKEDIN_APP_ID",
            "LIClientSecret": "REPLACE_ME_LINKEDIN_CLIENT_SECRET",
            "LIState": "REPLACE_ME_LINKEDIN_STATE",
            "LIRedirectUrl": "REPLACE_ME_LINKEDIN_REDIRECT_URL"
        ]
        
        XCTAssertNil(HLProfileViewController.linkedinConfiguration(from: info))
    }
    
    func testLinkedinConfigurationLoadsConfiguredValues() {
        let info: [String: Any] = [
            "LIAppId": "linkedin-client-id",
            "LIClientSecret": "linkedin-client-secret",
            "LIState": "oauth-state",
            "LIRedirectUrl": "https://hula.example/linkedin"
        ]
        
        let configuration = HLProfileViewController.linkedinConfiguration(from: info)
        
        XCTAssertEqual(configuration?.clientId, "linkedin-client-id")
        XCTAssertEqual(configuration?.clientSecret, "linkedin-client-secret")
        XCTAssertEqual(configuration?.state, "oauth-state")
        XCTAssertEqual(configuration?.redirectUrl, "https://hula.example/linkedin")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
