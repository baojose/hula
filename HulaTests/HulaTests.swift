//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import Foundation
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
    
    func testLinkedInConfigurationRejectsPublicPlaceholders() {
        let info: [String: Any] = [
            "LinkedInClientId": "YOUR_LINKEDIN_APP_ID",
            "LinkedInClientSecret": "REPLACE_ME_LINKEDIN_CLIENT_SECRET",
            "LinkedInState": "REPLACE_ME_LINKEDIN_STATE",
            "LinkedInRedirectURL": "https://hula.trading/"
        ]

        XCTAssertNil(HLProfileViewController.linkedinConfiguration(from: info))
    }

    func testLinkedInConfigurationRejectsMissingValues() {
        let info: [String: Any] = [
            "LinkedInClientId": "configured-client-id",
            "LinkedInState": "configured-state",
            "LinkedInRedirectURL": "https://hula.trading/"
        ]

        XCTAssertNil(HLProfileViewController.linkedinConfiguration(from: info))
    }

    func testLinkedInConfigurationAcceptsConfiguredValues() {
        let info: [String: Any] = [
            "LinkedInClientId": "configured-client-id",
            "LinkedInClientSecret": "configured-client-secret",
            "LinkedInState": "configured-state",
            "LinkedInRedirectURL": "https://hula.trading/"
        ]

        XCTAssertNotNil(HLProfileViewController.linkedinConfiguration(from: info))
    }

    func testHTTPParserRejectsMalformedJSONWithoutCrashing() {
        let response = httpResponse(statusCode: 200)
        let parsed = HLDataManager.parseHTTPResponse(data: "not-json".data(using: .utf8), response: response, error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPParserRejectsNonSuccessStatus() {
        let response = httpResponse(statusCode: 503)
        let parsed = HLDataManager.parseHTTPResponse(data: "{\"ok\":true}".data(using: .utf8), response: response, error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPParserRejectsMissingData() {
        let response = httpResponse(statusCode: 200)
        let parsed = HLDataManager.parseHTTPResponse(data: nil, response: response, error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPParserAcceptsValidJSON() {
        let response = httpResponse(statusCode: 200)
        let parsed = HLDataManager.parseHTTPResponse(data: "{\"ok\":true}".data(using: .utf8), response: response, error: nil)

        XCTAssertTrue(parsed.success)
        XCTAssertNotNil(parsed.json)
    }

    private func httpResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://hula.trading")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
