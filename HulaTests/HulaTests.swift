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

    func testPublicSnapshotKeepsSocialCredentialsUnset() {
        let credentialValues = [
            HulaConstants.twitterKey,
            HulaConstants.twitterSecret,
            HulaConstants.linkedinClientId,
            HulaConstants.linkedinClientSecret
        ]

        for credentialValue in credentialValues {
            XCTAssertEqual(credentialValue, "")
        }
    }

    func testLinkedInConfigurationUsesPublicSnapshotPlaceholders() {
        XCTAssertEqual(HulaConstants.linkedinState, "")
        XCTAssertEqual(HulaConstants.linkedinRedirectUrl, "https://hula.trading/")
        XCTAssertEqual(HulaConstants.linkedinPermissions, ["r_basicprofile", "r_emailaddress"])
    }
}
