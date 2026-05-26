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
        let url = URL(string: "https://example.com/test")!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
    
    func testParseJSONResponseAcceptsSuccessfulJSON() {
        let data = "{\"ok\":true}".data(using: String.Encoding.utf8)!
        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 200), error: nil)
        
        XCTAssertTrue(result.ok)
        XCTAssertNotNil(result.json)
    }
    
    func testParseJSONResponseRejectsInvalidJSON() {
        let data = "not-json".data(using: String.Encoding.utf8)!
        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 200), error: nil)
        
        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }
    
    func testParseJSONResponseRejectsHTTPError() {
        let data = "{\"message\":\"server error\"}".data(using: String.Encoding.utf8)!
        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 500), error: nil)
        
        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }
    
    func testParseJSONResponseRejectsNetworkError() {
        let data = "{\"ok\":true}".data(using: String.Encoding.utf8)!
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        let result = HLDataManager.parseJSONResponse(data: data, response: httpResponse(statusCode: 200), error: error)
        
        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }
    
}
