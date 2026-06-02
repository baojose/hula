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
    
    private func httpResponse(statusCode: Int) -> HTTPURLResponse {
        let url = URL(string: "https://api.hula.trading/v1/test")!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    func testParseJSONResponseAcceptsJSONSuccess() {
        let data = "{\"ok\":true}".data(using: .utf8)

        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 200), error: nil)

        XCTAssertTrue(result.ok)
        let dictionary = result.json as? [String: Any]
        XCTAssertEqual(dictionary?["ok"] as? Bool, true)
    }

    func testParseJSONResponseRejectsHTTPFailure() {
        let data = "{\"message\":\"expired\"}".data(using: .utf8)

        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 401), error: nil)

        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }

    func testParseJSONResponseRejectsInvalidJSON() {
        let data = "<html>Bad gateway</html>".data(using: .utf8)

        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 200), error: nil)

        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }
    
}
