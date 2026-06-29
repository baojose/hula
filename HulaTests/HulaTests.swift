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

    func testHTTPResponseParserRejectsMalformedJSON() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = "not-json".data(using: .utf8)

        let result = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }

    func testHTTPResponseParserRejectsServerErrors() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let data = "{\"message\":\"error\"}".data(using: .utf8)

        let result = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }

    func testHTTPResponseParserAcceptsValidJSON() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = "{\"ok\":true}".data(using: .utf8)

        let result = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertTrue(result.0)
        let dict = result.1 as? [String: Any]
        XCTAssertEqual(dict?["ok"] as? Bool, true)
    }

    func testLinkedInPlaceholderValuesAreRejected() {
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue(nil))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue(""))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("YOUR_LINKEDIN_APP_SECRET"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("REPLACE_ME_LINKEDIN_SECRET"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("$(LINKEDIN_SECRET)"))
        XCTAssertTrue(HLProfileViewController.isConfiguredLinkedinValue("configured-value"))
    }
    
}
