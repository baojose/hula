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
    
    func testHTTPResponseParserParsesSuccessfulJSON() {
        let url = URL(string: "https://api.hula.trading/v1/categories")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = "{\"ok\":true}".data(using: .utf8)

        let parsed = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertTrue(parsed.ok)
        XCTAssertNotNil(parsed.json)
    }
    
    func testHTTPResponseParserRejectsMalformedJSON() {
        let url = URL(string: "https://api.hula.trading/v1/categories")!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = "not-json".data(using: .utf8)

        let parsed = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(parsed.ok)
        XCTAssertNil(parsed.json)
    }

    func testHTTPResponseParserRejectsHTTPError() {
        let url = URL(string: "https://api.hula.trading/v1/authenticate")!
        let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        let data = "{\"message\":\"server error\"}".data(using: .utf8)

        let parsed = HLDataManager.parseHTTPResponse(data: data, response: response, error: nil)

        XCTAssertFalse(parsed.ok)
        XCTAssertNil(parsed.json)
    }

    func testLinkedInCredentialPlaceholdersAreRejected() {
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue(""))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue("YOUR_LINKEDIN_CLIENT_SECRET"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue("REPLACE_ME_LINKEDIN_STATE"))
        XCTAssertTrue(HLProfileViewController.isConfiguredLinkedInValue("configured-linkedin-value"))
    }

}
