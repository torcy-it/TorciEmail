//
//  CanSendTests.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//


import XCTest
@testable import TorciEmail

final class CanSendTests: XCTestCase {

    var viewModel: ComposeMailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ComposeMailViewModel(fromEmail: "torci.ado@outlook.it")
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_canSend_false_whenNoRecipient() {
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_false_whenSubjectEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.body = "Test body"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_false_whenSubjectOnlyWhitespace() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "   "
        viewModel.body = "Test body"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_false_whenBodyEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_false_whenBodyOnlyWhitespace() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        viewModel.body = "   \n\n"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_false_whenInvalidRecipientEmail() {
        viewModel.toRecipients = ["emailnonvalida"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_true_whenAllFieldsValid() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        XCTAssertTrue(viewModel.canSend)
    }

    func test_canSend_true_withRecipientInEmailNomeFormat() {
        viewModel.toRecipients = ["torci.ado@outlook.it<Adolfo>"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        XCTAssertTrue(viewModel.canSend)
    }

    func test_canSend_false_whenReplyToActiveAndInvalid() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = "nonemail"
        XCTAssertFalse(viewModel.canSend)
    }

    func test_canSend_true_whenReplyToActiveAndValid() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = "reply@test.com"
        XCTAssertTrue(viewModel.canSend)
    }

    func test_canSend_true_whenReplyToActiveButEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = ""
        XCTAssertTrue(viewModel.canSend)
    }
}
