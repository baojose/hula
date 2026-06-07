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
    
    func testLinkedInPlaceholderValuesAreRejected() {
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue(nil))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue(""))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue("YOUR_LINKEDIN_APP_ID"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue("REPLACE_ME_LINKEDIN_CLIENT_SECRET"))
        XCTAssertFalse(HLProfileViewController.isConfiguredLinkedInValue("$(LINKEDIN_CLIENT_SECRET)"))
        XCTAssertTrue(HLProfileViewController.isConfiguredLinkedInValue("configured-value"))
    }

    func testParseJSONResponseAcceptsSuccessfulJSON() {
        let data = "{\"ok\":true}".data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "https://hula.trading")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertTrue(result.ok)
        XCTAssertEqual((result.json as? NSDictionary)?.object(forKey: "ok") as? Bool, true)
    }

    func testParseJSONResponseRejectsHTTPError() {
        let data = "{\"message\":\"server error\"}".data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "https://hula.trading")!,
                                       statusCode: 500,
                                       httpVersion: nil,
                                       headerFields: nil)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }

    func testParseJSONResponseRejectsInvalidJSON() {
        let data = "not json".data(using: .utf8)

        let result = HLDataManager.parseJSONResponse(data: data, response: nil, error: nil)

        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
