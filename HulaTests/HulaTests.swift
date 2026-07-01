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
    
    func testLinkedInPlaceholderConfigurationIsRejected() {
        let placeholderInfo: [String: Any] = [
            "LIAppId": "YOUR_LINKEDIN_APP_ID",
            "LIAppSecret": "YOUR_LINKEDIN_APP_SECRET",
            "LIState": "YOUR_LINKEDIN_OAUTH_STATE",
            "LIRedirectURL": "YOUR_LINKEDIN_REDIRECT_URL"
        ]
        
        XCTAssertNil(HLProfileViewController.linkedinConfiguration(infoDictionary: placeholderInfo))
    }
    
    func testLinkedInConfigurationAcceptsPrivateValues() {
        let privateInfo: [String: Any] = [
            "LIAppId": "local-client-id",
            "LIAppSecret": "local-client-secret",
            "LIState": "local-oauth-state",
            "LIRedirectURL": "https://example.com/linkedin"
        ]
        
        XCTAssertNotNil(HLProfileViewController.linkedinConfiguration(infoDictionary: privateInfo))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
