//
//  CreateDraftCarbonCopyTests.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//


//
//  CreateDraftCarbonCopyTests.swift
//  TorciEmailTests
//
//  Created by Adolfo Torcicollo on 23/02/26.
//

import XCTest
@testable import TorciEmail

final class CreateDraftCarbonCopyTests: XCTestCase {

    var viewModel: ComposeMailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ComposeMailViewModel(fromEmail: "torci.ado@outlook.it")
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_createEmailDraft_noCarbonCopy_whenShowCcFalse() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showCc = false
        viewModel.ccRecipients = ["pippo@gmail.com"]

        let draft = viewModel.createEmailDraft()

        XCTAssertNil(draft?.carbonCopy)
    }

    func test_createEmailDraft_noCarbonCopy_whenCcEmpty() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showCc = true
        viewModel.ccRecipients = []

        let draft = viewModel.createEmailDraft()

        XCTAssertNil(draft?.carbonCopy)
    }

    func test_createEmailDraft_correctCarbonCopy_singleCc() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showCc = true
        viewModel.ccRecipients = ["pippo@gmail.com"]
        viewModel.ccRecipientsNames["pippo@gmail.com"] = "Pippo"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.carbonCopy?.count, 1)
        XCTAssertEqual(draft?.carbonCopy?[0].emailAddress, "pippo@gmail.com")
        XCTAssertEqual(draft?.carbonCopy?[0].name, "Pippo")
    }

    func test_createEmailDraft_correctCarbonCopy_multipleCc() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showCc = true
        viewModel.ccRecipients = ["pippo@gmail.com", "pluto@gmail.com"]
        viewModel.ccRecipientsNames["pippo@gmail.com"] = "Pippo"
        viewModel.ccRecipientsNames["pluto@gmail.com"] = "Pluto"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.carbonCopy?.count, 2)
        XCTAssertEqual(draft?.carbonCopy?[0].emailAddress, "pippo@gmail.com")
        XCTAssertEqual(draft?.carbonCopy?[0].name, "Pippo")
        XCTAssertEqual(draft?.carbonCopy?[1].emailAddress, "pluto@gmail.com")
        XCTAssertEqual(draft?.carbonCopy?[1].name, "Pluto")
    }

    func test_createEmailDraft_carbonCopy_extractsEmailFromFormat() {
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
        viewModel.showCc = true
        viewModel.ccRecipients = ["pippo@gmail.com<Pippo>"]
        viewModel.ccRecipientsNames["pippo@gmail.com<Pippo>"] = "Pippo"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.carbonCopy?[0].emailAddress, "pippo@gmail.com")
    }
}