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

    func testParseHTTPResponseAcceptsValidJSON() {
        let data = "{\"ok\":true}".data(using: .utf8)
        let parsed = HLDataManager.parseHTTPResponse(data: data, response: httpResponse(statusCode: 200), error: nil)
        let dictionary = parsed.json as? [String: Any]

        XCTAssertTrue(parsed.ok)
        XCTAssertEqual(dictionary?["ok"] as? Bool, true)
    }

    func testParseHTTPResponseRejectsMalformedJSON() {
        let data = "<html>not json</html>".data(using: .utf8)
        let parsed = HLDataManager.parseHTTPResponse(data: data, response: httpResponse(statusCode: 200), error: nil)

        XCTAssertFalse(parsed.ok)
        XCTAssertNil(parsed.json)
    }

    func testParseHTTPResponseRejectsHTTPError() {
        let data = "{\"ok\":true}".data(using: .utf8)
        let parsed = HLDataManager.parseHTTPResponse(data: data, response: httpResponse(statusCode: 500), error: nil)

        XCTAssertFalse(parsed.ok)
        XCTAssertNil(parsed.json)
    }

    func testLinkedInConfigRejectsPlaceholders() {
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue(nil))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue(""))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("YOUR_LINKEDIN_APP_ID"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedinValue("REPLACE_ME_LINKEDIN_STATE"))
        XCTAssertTrue(HLProfileViewController.isConfiguredLinkedinValue("configured-value"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    private func httpResponse(statusCode: Int) -> HTTPURLResponse {
        let url = URL(string: "https://api.hula.trading/v1/test")!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

}
