//
//  CreateDraftOptionsTests.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//


//
//  CreateDraftOptionsTests.swift
//  TorciEmailTests
//
//  Created by Adolfo Torcicollo on 23/02/26.
//

import XCTest
@testable import TorciEmail

final class CreateDraftOptionsTests: XCTestCase {

    var viewModel: ComposeMailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ComposeMailViewModel(fromEmail: "torci.ado@outlook.it")
        // Campi base sempre validi
        viewModel.toRecipients = ["torci.ado@outlook.it"]
        viewModel.subject = "Test"
        viewModel.body = "Body"
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_createEmailDraft_correctCertificationLevel() {
        viewModel.certificationLevel = "Advanced (EU)"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.certificationLevel, "Advanced (EU)")
    }

    func test_createEmailDraft_correctLanguage() {
        viewModel.language = "it"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.language, "it")
    }

    func test_createEmailDraft_correctAffidavitLanguage() {
        viewModel.affidavitLanguage = "it"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.affidavitLanguage, "it")
    }

    func test_createEmailDraft_correctAppearance() {
        viewModel.appearance = "As Is"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.appearance, "As Is")
    }

    func test_createEmailDraft_pushNotificationUrl_nilWhenDisabled() {
        viewModel.notarialDepositEnabled = false
        viewModel.notarialDepositURL = "https://example.com"

        let draft = viewModel.createEmailDraft()

        XCTAssertNil(draft?.options?.pushNotificationUrl)
    }

    func test_createEmailDraft_pushNotificationUrl_setWhenEnabled() {
        viewModel.notarialDepositEnabled = true
        viewModel.notarialDepositURL = "https://example.com"

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.pushNotificationUrl, "https://example.com")
    }

    func test_createEmailDraft_affidavitKinds_onlyEnabledSteps() {
        // Disabilita tutti
        for i in viewModel.affidavitSteps.indices {
            viewModel.affidavitSteps[i].isEnabled = false
        }
        // Abilita solo il primo
        viewModel.affidavitSteps[0].isEnabled = true

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.affidavitKinds.count, 1)
        XCTAssertEqual(draft?.options?.affidavitKinds.first, viewModel.affidavitSteps[0].title)
    }

    func test_createEmailDraft_affidavitKinds_emptyWhenAllDisabled() {
        for i in viewModel.affidavitSteps.indices {
            viewModel.affidavitSteps[i].isEnabled = false
        }

        let draft = viewModel.createEmailDraft()

        XCTAssertEqual(draft?.options?.affidavitKinds.count, 0)
    }

    func test_createEmailDraft_allowReasons_true() {
        viewModel.allowReasons = true
        viewModel.acceptReasons = ["Motivo 1", "Motivo 2"]
        viewModel.rejectReasons = ["Rifiuto 1"]

        let draft = viewModel.createEmailDraft()

        XCTAssertTrue(draft?.options?.allowReasons ?? false)
        XCTAssertEqual(draft?.options?.acceptReasons, ["Motivo 1", "Motivo 2"])
        XCTAssertEqual(draft?.options?.rejectReasons, ["Rifiuto 1"])
    }

    func test_createEmailDraft_reasonsRequired() {
        viewModel.allowReasons = true
        viewModel.acceptReasonsRequired = true
        viewModel.rejectReasonsRequired = true

        let draft = viewModel.createEmailDraft()

        XCTAssertTrue(draft?.options?.acceptReasonsRequired ?? false)
        XCTAssertTrue(draft?.options?.rejectReasonsRequired ?? false)
    }
}