//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import Foundation
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
    
    func testJSONResponseParserAcceptsValidJSON() {
        let data = "{\"ok\":true}".data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertTrue(result.0)
        let dictionary = result.1 as? [String: Any]
        XCTAssertEqual(dictionary?["ok"] as? Bool, true)
    }

    func testJSONResponseParserRejectsNetworkErrors() {
        let error = NSError(domain: "HulaTests", code: -1, userInfo: nil)

        let result = HLDataManager.parseJSONResponse(data: nil, response: nil, error: error)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }

    func testJSONResponseParserRejectsHTTPErrorBodies() {
        let data = "<html>Service Unavailable</html>".data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 503, httpVersion: nil, headerFields: nil)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }

    func testJSONResponseParserRejectsMalformedJSON() {
        let data = "<html>not json</html>".data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
