//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testOnboardingPlayerStoreKeepsSplashPlayerAlive() {
        let store = OnboardingPlayerStore()
        _ = store.replace(url: URL(fileURLWithPath: "/tmp/hula-splash-missing.mp4"), frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        XCTAssertTrue(store.hasRetainedPlayer)
        store.stop()
        XCTAssertFalse(store.hasRetainedPlayer)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
