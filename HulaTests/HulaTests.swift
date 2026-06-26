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
    
    func testLinkedInConfigurationRejectsPlaceholders() {
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue(nil))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue(""))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("YOUR_LINKEDIN_APP_ID"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("REPLACE_ME_LINKEDIN_CLIENT_SECRET"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("$(LINKEDIN_CLIENT_SECRET)"))
        XCTAssertTrue(HLProfileViewController.isConfiguredLinkedinValue("real-linked-in-value"))
    }

    func testHTTPResponseParserRejectsMalformedJSON() {
        let data = "not json".data(using: String.Encoding.utf8)
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/me")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)

        let parsed = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPResponseParserRejectsHTTPFailures() {
        let data = "{\"message\":\"error\"}".data(using: String.Encoding.utf8)
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/me")!,
                                       statusCode: 500,
                                       httpVersion: nil,
                                       headerFields: nil)

        let parsed = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPResponseParserReturnsJSONForSuccessfulResponse() {
        let data = "{\"ok\":true}".data(using: String.Encoding.utf8)
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/me")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)

        let parsed = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertTrue(parsed.success)
        XCTAssertNotNil(parsed.json as? [String: Any])
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
