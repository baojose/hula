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
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Close Deal / donation: stay in room until network completes

    func testShouldNotReturnToLobbyAfterCloseDealConfirmation() {
        XCTAssertFalse(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "doit", response: "ok"))
        XCTAssertFalse(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "doit", response: "cancel"))
    }

    func testShouldNotReturnToLobbyAfterDonationConfirmation() {
        XCTAssertFalse(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "donation", response: "ok"))
        XCTAssertFalse(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "donation", response: "cancel"))
    }

    func testShouldNotReturnToLobbyForTradeFailureAlert() {
        XCTAssertFalse(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "notrade", response: "ok"))
    }

    func testShouldReturnToLobbyAfterSuccessAcknowledged() {
        XCTAssertTrue(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "deal_review", response: "ok"))
        XCTAssertTrue(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "deal_closed", response: "ok"))
        XCTAssertTrue(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "feedback_sent", response: "ok"))
        XCTAssertTrue(HLSwappViewController.shouldReturnToLobbyAfterAlert(trigger: "", response: "ok"))
    }

    // MARK: - Chat: no portrait poll auto-dismiss

    func testChatShouldNotAutoDismissOnPortraitOrientation() {
        XCTAssertFalse(ChatViewController.shouldAutoDismissForOrientation(.portrait))
        XCTAssertFalse(ChatViewController.shouldAutoDismissForOrientation(.portraitUpsideDown))
        XCTAssertFalse(ChatViewController.shouldAutoDismissForOrientation(.landscapeLeft))
        XCTAssertFalse(ChatViewController.shouldAutoDismissForOrientation(.faceUp))
        XCTAssertFalse(ChatViewController.shouldAutoDismissForOrientation(.unknown))
    }
}
