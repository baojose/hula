//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
import LinkedinSwift
@testable import Hula

class HulaTests: XCTestCase {

    func testSocialCredentialConstantsRemainPublicPlaceholders() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
        XCTAssertEqual(HulaConstants.linkedinClientId, "")
        XCTAssertEqual(HulaConstants.linkedinClientSecret, "")
        XCTAssertEqual(HulaConstants.linkedinState, "")
    }

    func testLinkedinConfigurationUsesCentralizedPublicSnapshotValues() {
        let configuration = HLProfileViewController.linkedinConfiguration()

        XCTAssertEqual(configuration.clientId, HulaConstants.linkedinClientId)
        XCTAssertEqual(configuration.clientSecret, HulaConstants.linkedinClientSecret)
        XCTAssertEqual(configuration.state, HulaConstants.linkedinState)
        XCTAssertEqual(configuration.permissions as? [String] ?? [], HulaConstants.linkedinPermissions)
        XCTAssertEqual(configuration.redirectUrl, HulaConstants.linkedinRedirectURL)
    }

    func testLinkedinConfigurationKeepsRequiredOAuthShapeWithoutSecrets() {
        let configuration = HLProfileViewController.linkedinConfiguration()

        XCTAssertTrue(configuration.clientId.isEmpty)
        XCTAssertTrue(configuration.clientSecret.isEmpty)
        XCTAssertTrue(configuration.state.isEmpty)
        XCTAssertEqual(configuration.permissions as? [String] ?? [], ["r_basicprofile", "r_emailaddress"])
        XCTAssertEqual(configuration.redirectUrl, "https://hula.trading/")
    }
}
