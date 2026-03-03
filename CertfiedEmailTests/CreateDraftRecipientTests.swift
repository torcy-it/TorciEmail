//
//  CreateDraftRecipientTests.swift
//  CertfiedEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//


import XCTest
@testable import CertfiedEmail

final class CreateDraftRecipientTests: XCTestCase {

    var viewModel: ComposeMailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ComposeMailViewModel(fromEmail: "torci.ado@outlook.it")
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_createEmailDraft_correctRecipientEmail() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.recipientEmail, "torci.ado@outlook.it")
    }

    func test_createEmailDraft_correctRecipientName() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.recipientNames["torci.ado@outlook.it"] = "Adolfo"
        viewModel.subject = "Test"
        viewModel.body = "Body"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.recipientName, "Adolfo")
    }

    func test_createEmailDraft_extractsEmailFromFormat() {
        // Formato email<nome>
        viewModel.toRecipients = ["torci.ado@outlook.it<Adolfo Torcicollo>"]
        viewModel.subject = "Test"
        viewModel.body = "Body"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.recipientEmail, "torci.ado@outlook.it")
    }

    func test_createEmailDraft_extractsEmailWithSpaceBeforeBracket() {
        // Formato email <nome> con spazio
        viewModel.toRecipients = ["torci.ado@outlook.it <Adolfo>"]
        viewModel.subject = "Test"
        viewModel.body = "Body"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.recipientEmail, "torci.ado@outlook.it")
    }

    func test_createEmailDraft_replyTo_setWhenActiveAndFilled() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = "reply@test.com"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.replyTo, "reply@test.com")
    }

    func test_createEmailDraft_replyTo_nilWhenToggleOff() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showReplyTo = false
        viewModel.replyToAddress = "reply@test.com"

        let draft = viewModel.createEmailDraft()

        XCTAssertNil(draft?.replyTo)
    }

    func test_createEmailDraft_replyTo_nilWhenEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = ""

        let draft = viewModel.createEmailDraft()

        XCTAssertNil(draft?.replyTo)
    }
}
