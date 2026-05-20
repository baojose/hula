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

    func testTwitterCredentialsAreBlankInPublicDefaults() {
        XCTAssertEqual(HulaConstants.twitterKey, "")
        XCTAssertEqual(HulaConstants.twitterSecret, "")
    }

    func testInfoPlistKeepsSocialProviderCredentialsAsPlaceholders() {
        let info = Bundle.main.infoDictionary ?? [:]

        guard let urlTypes = info["CFBundleURLTypes"] as? [[String: Any]] else {
            XCTFail("Expected CFBundleURLTypes to be present")
            return
        }

        var schemes = [String]()
        for urlType in urlTypes {
            if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] {
                schemes.append(contentsOf: urlSchemes)
            }
        }

        XCTAssertTrue(schemes.contains("liYOUR_LINKEDIN_APP_ID"))
        XCTAssertTrue(schemes.contains("fbYOUR_FACEBOOK_APP_ID"))
        XCTAssertTrue(schemes.contains("twitterkit-REPLACE_ME_TWITTER_CONSUMER_KEY"))

        XCTAssertEqual(info["FacebookAppID"] as? String, "YOUR_FACEBOOK_APP_ID")
        XCTAssertEqual(info["LIAppId"] as? String, "YOUR_LINKEDIN_APP_ID")

        guard let fabric = info["Fabric"] as? [String: Any] else {
            XCTFail("Expected Fabric configuration to be present")
            return
        }

        XCTAssertEqual(fabric["APIKey"] as? String, "REPLACE_ME_FABRIC_API_KEY")

        guard let kits = fabric["Kits"] as? [[String: Any]],
            let twitterKit = kits.first(where: { ($0["KitName"] as? String) == "Twitter" }),
            let kitInfo = twitterKit["KitInfo"] as? [String: Any] else {
                XCTFail("Expected Twitter Fabric kit configuration to be present")
                return
        }

        XCTAssertEqual(kitInfo["consumerKey"] as? String, "REPLACE_ME_TWITTER_CONSUMER_KEY")
        XCTAssertEqual(kitInfo["consumerSecret"] as? String, "REPLACE_ME_TWITTER_CONSUMER_SECRET")
    }

    func testFirebaseConfigurationKeepsPublicPlaceholders() {
        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let firebaseConfig = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else {
                XCTFail("Expected GoogleService-Info.plist to be bundled")
                return
        }

        XCTAssertEqual(firebaseConfig["TRACKING_ID"] as? String, "REPLACE_ME_ANALYTICS_TRACKING_ID")
        XCTAssertEqual(firebaseConfig["CLIENT_ID"] as? String, "REPLACE_ME-YOUR_NUMERIC_PART.apps.googleusercontent.com")
        XCTAssertEqual(firebaseConfig["REVERSED_CLIENT_ID"] as? String, "com.googleusercontent.apps.REPLACE_ME")
        XCTAssertEqual(firebaseConfig["API_KEY"] as? String, "REPLACE_ME_FIREBASE_IOS_API_KEY")
        XCTAssertEqual(firebaseConfig["GCM_SENDER_ID"] as? String, "REPLACE_ME_GCM_SENDER")
        XCTAssertEqual(firebaseConfig["PROJECT_ID"] as? String, "replace-me-firebase-project")
        XCTAssertEqual(firebaseConfig["STORAGE_BUCKET"] as? String, "replace-me-firebase-project.appspot.com")
        XCTAssertEqual(firebaseConfig["GOOGLE_APP_ID"] as? String, "1:REPLACE_ME:ios:REPLACE_ME")
        XCTAssertEqual(firebaseConfig["DATABASE_URL"] as? String, "https://replace-me-default-rtdb.firebaseio.com")
    }
}
