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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testLinkedInConfigurationRejectsPlaceholders() {
        let info: [String: Any] = [
            LinkedInOAuthConfiguration.clientIdKey: "YOUR_LINKEDIN_APP_ID",
            LinkedInOAuthConfiguration.clientSecretKey: "REPLACE_ME_LINKEDIN_CLIENT_SECRET",
            LinkedInOAuthConfiguration.stateKey: "REPLACE_ME_LINKEDIN_STATE",
            LinkedInOAuthConfiguration.redirectURLKey: "https://hula.trading/"
        ]

        XCTAssertNil(LinkedInOAuthConfiguration.from(infoDictionary: info))
        XCTAssertNil(LinkedInOAuthConfiguration.configuredValue("REPLACE_ME_LINKEDIN_CLIENT_SECRET"))
        XCTAssertNil(LinkedInOAuthConfiguration.configuredValue("YOUR_LINKEDIN_APP_ID"))
    }

    func testLinkedInConfigurationLoadsInjectedValues() {
        let info: [String: Any] = [
            LinkedInOAuthConfiguration.clientIdKey: "real-client-id",
            LinkedInOAuthConfiguration.clientSecretKey: "real-client-secret",
            LinkedInOAuthConfiguration.stateKey: "real-state",
            LinkedInOAuthConfiguration.redirectURLKey: "https://hula.trading/"
        ]

        let config = LinkedInOAuthConfiguration.from(infoDictionary: info)
        XCTAssertEqual(config?.clientId, "real-client-id")
        XCTAssertEqual(config?.clientSecret, "real-client-secret")
        XCTAssertEqual(config?.state, "real-state")
        XCTAssertEqual(config?.redirectURL, "https://hula.trading/")
    }

    func testHTTPResponseParserRejectsMalformedJSON() {
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/test")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let result = HLDataManager.parseHTTPResponse(data: "not-json".data(using: .utf8), response: response, error: nil)

        XCTAssertFalse(result.success)
        XCTAssertNil(result.json)
    }

    func testHTTPResponseParserRejectsNonSuccessStatusCode() {
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/test")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let result = HLDataManager.parseHTTPResponse(data: "{\"ok\":true}".data(using: .utf8), response: response, error: nil)

        XCTAssertFalse(result.success)
        XCTAssertNil(result.json)
    }

    func testHTTPResponseParserAcceptsValidJSON() {
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/test")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let result = HLDataManager.parseHTTPResponse(data: "{\"ok\":true}".data(using: .utf8), response: response, error: nil)

        XCTAssertTrue(result.success)
        XCTAssertNotNil(result.json)
    }

}
