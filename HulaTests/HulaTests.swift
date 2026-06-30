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
    
    private func httpResponse(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

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
    
    func testHTTPResponseParserRejectsMalformedJSON() {
        let data = "not json".data(using: String.Encoding.utf8)
        let parsed = HLDataManager.parseHTTPResponse(data: data, response: httpResponse(statusCode: 200), error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPResponseParserRejectsNonSuccessStatusCode() {
        let data = "{\"ok\":true}".data(using: String.Encoding.utf8)
        let parsed = HLDataManager.parseHTTPResponse(data: data, response: httpResponse(statusCode: 500), error: nil)

        XCTAssertFalse(parsed.success)
        XCTAssertNil(parsed.json)
    }

    func testHTTPResponseParserAcceptsSuccessJSON() {
        let data = "{\"ok\":true}".data(using: String.Encoding.utf8)
        let parsed = HLDataManager.parseHTTPResponse(data: data, response: httpResponse(statusCode: 200), error: nil)

        XCTAssertTrue(parsed.success)
        XCTAssertNotNil(parsed.json)
    }

    func testProductPopulateIgnoresMalformedLocation() {
        let product = HulaProduct()

        product.populate(with: ["location": []] as NSDictionary)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 0.0, accuracy: 0.001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, 0.0, accuracy: 0.001)

        product.populate(with: ["location": [NSNumber(value: 51.5), "-0.12"] as [Any]] as NSDictionary)
        XCTAssertEqual(product.productLocation.coordinate.latitude, 51.5, accuracy: 0.001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -0.12, accuracy: 0.001)
    }

    func testLinkedInPlaceholdersAreRejected() {
        XCTAssertFalse(HLProfileViewController.isLinkedinConfigValueUsable(""))
        XCTAssertFalse(HLProfileViewController.isLinkedinConfigValueUsable("YOUR_LINKEDIN_APP_SECRET"))
        XCTAssertFalse(HLProfileViewController.isLinkedinConfigValueUsable("REPLACE_ME_LINKEDIN_SECRET"))
        XCTAssertTrue(HLProfileViewController.isLinkedinConfigValueUsable("configured-value"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
