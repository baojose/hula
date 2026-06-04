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

    func testLinkedinConfigurationRejectsPlaceholders() {
        let info: [String: Any] = [
            "LIAppId": "YOUR_LINKEDIN_APP_ID",
            "LIClientSecret": "REPLACE_ME_LINKEDIN_CLIENT_SECRET",
            "LIState": "REPLACE_ME_LINKEDIN_STATE",
            "LIRedirectUrl": "REPLACE_ME_LINKEDIN_REDIRECT_URL"
        ]

        XCTAssertNil(HLProfileViewController.linkedinConfiguration(from: info))
    }

    func testLinkedinConfigurationLoadsConfiguredValues() {
        let info: [String: Any] = [
            "LIAppId": "linkedin-client-id",
            "LIClientSecret": "linkedin-client-secret",
            "LIState": "oauth-state",
            "LIRedirectUrl": "https://hula.example/linkedin"
        ]

        let configuration = HLProfileViewController.linkedinConfiguration(from: info)

        XCTAssertEqual(configuration?.clientId, "linkedin-client-id")
        XCTAssertEqual(configuration?.clientSecret, "linkedin-client-secret")
        XCTAssertEqual(configuration?.state, "oauth-state")
        XCTAssertEqual(configuration?.redirectUrl, "https://hula.example/linkedin")
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

    func testParseJSONResponseRejectsTransportError() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)

        let result = HLDataManager.parseJSONResponse(data: nil, response: nil, error: error)

        XCTAssertFalse(result.ok)
        XCTAssertNil(result.json)
    }

}
