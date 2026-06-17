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

    func testHTTPResponseParserRejectsInvalidJSON() {
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/me")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        let data = "not json".data(using: String.Encoding.utf8)

        let parsedResponse = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(parsedResponse.ok)
        XCTAssertNil(parsedResponse.json)
    }

    func testHTTPResponseParserRejectsHTTPFailures() {
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/me")!,
                                       statusCode: 500,
                                       httpVersion: nil,
                                       headerFields: nil)
        let data = "{\"message\":\"server error\"}".data(using: String.Encoding.utf8)

        let parsedResponse = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(parsedResponse.ok)
        XCTAssertNil(parsedResponse.json)
    }

    func testHTTPResponseParserAcceptsValidJSON() {
        let response = HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/me")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        let data = "{\"ok\":true}".data(using: String.Encoding.utf8)

        let parsedResponse = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertTrue(parsedResponse.ok)
        XCTAssertNotNil(parsedResponse.json)
    }

    func testLinkedinPlaceholderValuesAreRejected() {
        XCTAssertNil(HLProfileViewController.sanitizedLinkedinValue("REPLACE_ME_LINKEDIN_CLIENT_SECRET"))
        XCTAssertNil(HLProfileViewController.sanitizedLinkedinValue("YOUR_LINKEDIN_APP_ID"))
        XCTAssertNil(HLProfileViewController.sanitizedLinkedinValue("$(LINKEDIN_CLIENT_SECRET)"))
        XCTAssertNil(HLProfileViewController.sanitizedLinkedinValue("   "))
    }

    func testLinkedinConfiguredValuesAreTrimmed() {
        XCTAssertEqual(HLProfileViewController.sanitizedLinkedinValue("  real-client-id  "), "real-client-id")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
