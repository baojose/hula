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
    
    func testParseJSONResponseRejectsTransportError() {
        let data = "{}".data(using: .utf8)
        let error = NSError(domain: "network", code: -1, userInfo: nil)

        let result = HLDataManager.parseJSONResponse(data: data, response: nil, error: error)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }
    
    func testParseJSONResponseRejectsHTTPFailure() {
        let data = "{\"ok\":true}".data(using: .utf8)
        let response = httpResponse(statusCode: 500)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }

    func testParseJSONResponseRejectsMalformedJSON() {
        let data = "server error".data(using: .utf8)
        let response = httpResponse(statusCode: 200)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertFalse(result.0)
        XCTAssertNil(result.1)
    }

    func testParseJSONResponseAcceptsSuccessfulJSON() {
        let data = "{\"ok\":true}".data(using: .utf8)
        let response = httpResponse(statusCode: 200)

        let result = HLDataManager.parseJSONResponse(data: data, response: response, error: nil)

        XCTAssertTrue(result.0)
        let dictionary = result.1 as? [String: Bool]
        XCTAssertTrue(dictionary?["ok"] == true)
    }

    private func httpResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://api.hula.trading/v1/test")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
}
