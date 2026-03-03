//
//  CreateDraftBaseTests.swift
//  CertfiedEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//

import XCTest
@testable import CertfiedEmail

final class CreateDraftBaseTests: XCTestCase {

    var viewModel: ComposeMailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ComposeMailViewModel(fromEmail: "torci.ado@outlook.it")
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_createEmailDraft_nil_whenNoRecipient() {
        viewModel.subject = "Test"
        viewModel.body = "Body"
        XCTAssertNil(viewModel.createEmailDraft())
    }

    func test_createEmailDraft_nil_whenSubjectEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.body = "Body"
        XCTAssertNil(viewModel.createEmailDraft())
    }

    func test_createEmailDraft_nil_whenBodyEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        XCTAssertNil(viewModel.createEmailDraft())
    }

    func test_createEmailDraft_correctSubjectAndBody() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test subject"
        viewModel.body = "Test body"

        let draft = viewModel.createEmailDraft()

        XCTAssertNotNil(draft)
        XCTAssertEqual(draft?.subject, "Test subject")
        XCTAssertEqual(draft?.body, "Test body")
    }
}
