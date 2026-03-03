//
//  JSONCaptureMockRepository.swift
//  CertfiedEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//


import XCTest
@testable import CertfiedEmail

// MARK: - Mock Repository che cattura il JSON inviato
final class JSONCaptureMockRepository: EmailRepository {

    var capturedJSON: [String: Any]?
    var shouldSucceed: Bool = true

    func sendEmail(_ draft: EmailDraft) async throws -> String {
        // Ricostruiamo il submit request esattamente come fa EmailRepositoryImpl
        let mapper = EmailRepositoryImpl()
        let submitRequest = mapper.buildSubmitRequest(from: draft)

        // Serializziamo in JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(submitRequest)

        // Salviamo come dizionario per confronto campo per campo
        capturedJSON = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

        // Stampa il JSON in console per debug
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 JSON inviato:\n\(jsonString)")
        }

        if shouldSucceed { return "fake-evi-id-123" }
        throw RepositoryError.networkError
    }

    func getAllEmails() async throws -> [EmailItem] { [] }
    func getEmail(id: String) async throws -> EmailItem { throw RepositoryError.emailNotFound }
}

// MARK: - Estensione per esporre buildSubmitRequest nei test
extension EmailRepositoryImpl {
    func buildSubmitRequest(from draft: EmailDraft) -> EviMailSubmitRequest {
        let carbonCopy: [SubmitCarbonCopy]? = draft.carbonCopy?.map {
            SubmitCarbonCopy(name: $0.name, emailAddress: $0.emailAddress)
        }

        let options: SubmitOptions? = draft.options.map { opts in
            SubmitOptions(
                costCentre: nil,
                certificationLevel: opts.certificationLevel,
                affidavitsOnDemandEnabled: true,
                timeToLive: opts.timeToLive,
                hideBanners: false,
                language: opts.language,
                affidavitLanguage: opts.affidavitLanguage,
                evidenceAccessControlMethod: nil,
                evidenceAccessControlChallenge: nil,
                evidenceAccessControlChallengeResponse: nil,
                onlineRetentionPeriod: 1,
                deliveryMode: opts.deliveryMode,
                whatsAppPinPolicy: "Optional",
                commitmentOptions: opts.commitmentOptions,
                commitmentCommentsAllowed: opts.allowReasons,
                rejectReasons: opts.rejectReasons,
                acceptReasons: opts.acceptReasons,
                requireRejectReason: opts.rejectReasonsRequired,
                requireAcceptReason: opts.acceptReasonsRequired,
                pushNotificationUrl: opts.pushNotificationUrl,
                pushNotificationFilter: nil,
                affidavitKinds: opts.affidavitKinds,
                customLayoutLogoUrl: nil,
                pushNotificationExtraData: nil
            )
        }

        return EviMailSubmitRequest(
            subject: draft.subject,
            body: draft.body,
            issuerName: draft.issuerName,
            replyTo: draft.replyTo,
            disableSenderHeader: false,
            recipient: SubmitRecipient(
                legalName: draft.recipientName,
                emailAddress: draft.recipientEmail
            ),
            carbonCopy: carbonCopy,
            options: options,
            attachments: nil
        )
    }
}

// MARK: - JSON Integration Tests
final class JSONIntegrationTests: XCTestCase {

    var viewModel: ComposeMailViewModel!
    var mockRepo: JSONCaptureMockRepository!

    override func setUp() {
        super.setUp()
        mockRepo = JSONCaptureMockRepository()
        viewModel = ComposeMailViewModel(
            fromEmail: "torci.ado@outlook.it",
            emailRepository: mockRepo
        )
    }

    override func tearDown() {
        viewModel = nil
        mockRepo = nil
        super.tearDown()
    }

    // MARK: - Helper per leggere valori dal JSON catturato

    private func json(_ key: String) -> Any? {
        mockRepo.capturedJSON?[key]
    }

    private func jsonRecipient() -> [String: Any]? {
        mockRepo.capturedJSON?["Recipient"] as? [String: Any]
    }

    private func jsonOptions() -> [String: Any]? {
        mockRepo.capturedJSON?["Options"] as? [String: Any]
    }

    private func jsonCarbonCopy() -> [[String: Any]]? {
        mockRepo.capturedJSON?["CarbonCopy"] as? [[String: Any]]
    }

    // MARK: - Test 1: Email base (solo campi obbligatori)

    func test_json_baseEmail() async throws {
        // Setup — simulo quello che l'utente inserisce nella view
        viewModel.toRecipients = ["sp4m3il@gmail.com<Mario Rossi>"]
        viewModel.recipientNames["sp4m3il@gmail.com<Mario Rossi>"] = "Mario Rossi"
        viewModel.subject = "Test base"
        viewModel.body = "Corpo del messaggio"

        // JSON atteso
        let expectedJSON: [String: Any] = [
            "Subject": "Test base",
            "Body": "Corpo del messaggio",
            "IssuerName": "NamirialTest-LC",
            "DisableSenderHeader": false,
            "Recipient": [
                "LegalName": "Mario Rossi",
                "EmailAddress": "sp4m3il@gmail.com"
            ]
        ]

        // Invio
        _ = await viewModel.sendEmail()

        // Verifico campo per campo
        XCTAssertEqual(json("Subject") as? String, expectedJSON["Subject"] as? String)
        XCTAssertEqual(json("Body") as? String, expectedJSON["Body"] as? String)
        XCTAssertEqual(json("IssuerName") as? String, expectedJSON["IssuerName"] as? String)
        XCTAssertEqual(json("DisableSenderHeader") as? Bool, expectedJSON["DisableSenderHeader"] as? Bool)
        XCTAssertEqual(jsonRecipient()?["EmailAddress"] as? String, "sp4m3il@gmail.com")
        XCTAssertEqual(jsonRecipient()?["LegalName"] as? String, "Mario Rossi")
    }

    // MARK: - Test 2: Email con CC multipli

    func test_json_withMultipleCarbonCopy() async throws {
        viewModel.toRecipients = ["sp4m3il@gmail.com<Mario Rossi>"]
        viewModel.recipientNames["sp4m3il@gmail.com<Mario Rossi>"] = "Mario Rossi"
        viewModel.subject = "Test CC"
        viewModel.body = "Corpo"
        viewModel.showCc = true
        viewModel.ccRecipients = ["pippo@gmail.com", "pluto@gmail.com"]
        viewModel.ccRecipientsNames["pippo@gmail.com"] = "Pippo"
        viewModel.ccRecipientsNames["pluto@gmail.com"] = "Pluto"

        _ = await viewModel.sendEmail()

        let cc = jsonCarbonCopy()
        XCTAssertNotNil(cc)
        XCTAssertEqual(cc?.count, 2)
        XCTAssertEqual(cc?[0]["EmailAddress"] as? String, "pippo@gmail.com")
        XCTAssertEqual(cc?[0]["Name"] as? String, "Pippo")
        XCTAssertEqual(cc?[1]["EmailAddress"] as? String, "pluto@gmail.com")
        XCTAssertEqual(cc?[1]["Name"] as? String, "Pluto")
    }

    // MARK: - Test 3: Email con ReplyTo

    func test_json_withReplyTo() async throws {
        viewModel.toRecipients = ["sp4m3il@gmail.com"]
        viewModel.subject = "Test ReplyTo"
        viewModel.body = "Corpo"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = "reply@test.com"

        _ = await viewModel.sendEmail()

        XCTAssertEqual(json("ReplyTo") as? String, "reply@test.com")
    }

    // MARK: - Test 4: Options — lingua e certification level

    func test_json_options_languageAndCertification() async throws {
        viewModel.toRecipients = ["sp4m3il@gmail.com"]
        viewModel.subject = "Test Options"
        viewModel.body = "Corpo"
        viewModel.language = "it"
        viewModel.affidavitLanguage = "it"
        viewModel.certificationLevel = "Advanced (EU)"

        _ = await viewModel.sendEmail()

        let opts = jsonOptions()
        XCTAssertEqual(opts?["Language"] as? String, "it")
        XCTAssertEqual(opts?["AffidavitLanguage"] as? String, "it")
        XCTAssertEqual(opts?["CertificationLevel"] as? String, "Advanced (EU)")
    }

    // MARK: - Test 5: Options — accept/reject reasons

    func test_json_options_reasons() async throws {
        viewModel.toRecipients = ["sp4m3il@gmail.com"]
        viewModel.subject = "Test Reasons"
        viewModel.body = "Corpo"
        viewModel.allowReasons = true
        viewModel.agreementPossibilities = "Accept / Reject"
        viewModel.acceptReasons = ["Motivo A", "Motivo B"]
        viewModel.rejectReasons = ["Rifiuto 1"]
        viewModel.acceptReasonsRequired = true
        viewModel.rejectReasonsRequired = false

        _ = await viewModel.sendEmail()

        let opts = jsonOptions()
        XCTAssertEqual(opts?["CommitmentCommentsAllowed"] as? Bool, true)
        XCTAssertEqual(opts?["AcceptReasons"] as? [String], ["Motivo A", "Motivo B"])
        XCTAssertEqual(opts?["RejectReasons"] as? [String], ["Rifiuto 1"])
        XCTAssertEqual(opts?["RequireAcceptReason"] as? Bool, true)
        XCTAssertEqual(opts?["RequireRejectReason"] as? Bool, false)
    }

    // MARK: - Test 6: Options — affidavit kinds

    func test_json_options_affidavitKinds() async throws {
        viewModel.toRecipients = ["sp4m3il@gmail.com"]
        viewModel.subject = "Test Affidavit"
        viewModel.body = "Corpo"

        // Disabilita tutti, abilita solo i primi 2
        for i in viewModel.affidavitSteps.indices {
            viewModel.affidavitSteps[i].isEnabled = false
        }
        viewModel.affidavitSteps[0].isEnabled = true
        viewModel.affidavitSteps[1].isEnabled = true

        _ = await viewModel.sendEmail()

        let kinds = jsonOptions()?["AffidavitKinds"] as? [String]
        XCTAssertEqual(kinds?.count, 2)
        XCTAssertEqual(kinds?[0], viewModel.affidavitSteps[0].title)
        XCTAssertEqual(kinds?[1], viewModel.affidavitSteps[1].title)
    }

    // MARK: - Test 7: Options — push notification URL

    func test_json_options_pushNotificationUrl() async throws {
        viewModel.toRecipients = ["sp4m3il@gmail.com"]
        viewModel.subject = "Test Push"
        viewModel.body = "Corpo"
        viewModel.notarialDepositEnabled = true
        viewModel.notarialDepositURL = "https://myserver.com/webhook"

        _ = await viewModel.sendEmail()

        XCTAssertEqual(jsonOptions()?["PushNotificationUrl"] as? String, "https://myserver.com/webhook")
    }

    // MARK: - Test 8: Email completa (tutti i campi)

    func test_json_fullEmail() async throws {
        // Simulo un utente che compila tutto
        viewModel.toRecipients = ["sp4m3il@gmail.com<Mario Rossi>"]
        viewModel.recipientNames["sp4m3il@gmail.com<Mario Rossi>"] = "Mario Rossi"
        viewModel.subject = "Email completa"
        viewModel.body = "Corpo completo"
        viewModel.issuerName = "NamirialTest-LC"
        viewModel.showCc = true
        viewModel.ccRecipients = ["pippo@gmail.com"]
        viewModel.ccRecipientsNames["pippo@gmail.com"] = "Pippo"
        viewModel.showReplyTo = true
        viewModel.replyToAddress = "reply@test.com"
        viewModel.language = "it"
        viewModel.affidavitLanguage = "it"
        viewModel.certificationLevel = "Advanced (EU)"
        viewModel.allowReasons = true
        viewModel.acceptReasons = ["Accetto"]
        viewModel.rejectReasons = ["Rifiuto"]
        viewModel.acceptReasonsRequired = true
        viewModel.rejectReasonsRequired = true
        viewModel.notarialDepositEnabled = true
        viewModel.notarialDepositURL = "https://myserver.com/webhook"

        _ = await viewModel.sendEmail()

        // Verifico tutto il JSON
        XCTAssertEqual(json("Subject") as? String, "Email completa")
        XCTAssertEqual(json("Body") as? String, "Corpo completo")
        XCTAssertEqual(json("IssuerName") as? String, "NamirialTest-LC")
        XCTAssertEqual(json("ReplyTo") as? String, "reply@test.com")
        XCTAssertEqual(json("DisableSenderHeader") as? Bool, false)

        XCTAssertEqual(jsonRecipient()?["EmailAddress"] as? String, "sp4m3il@gmail.com")
        XCTAssertEqual(jsonRecipient()?["LegalName"] as? String, "Mario Rossi")

        XCTAssertEqual(jsonCarbonCopy()?.count, 1)
        XCTAssertEqual(jsonCarbonCopy()?[0]["EmailAddress"] as? String, "pippo@gmail.com")
        XCTAssertEqual(jsonCarbonCopy()?[0]["Name"] as? String, "Pippo")

        let opts = jsonOptions()
        XCTAssertEqual(opts?["Language"] as? String, "it")
        XCTAssertEqual(opts?["AffidavitLanguage"] as? String, "it")
        XCTAssertEqual(opts?["CertificationLevel"] as? String, "Advanced (EU)")
        XCTAssertEqual(opts?["CommitmentCommentsAllowed"] as? Bool, true)
        XCTAssertEqual(opts?["AcceptReasons"] as? [String], ["Accetto"])
        XCTAssertEqual(opts?["RejectReasons"] as? [String], ["Rifiuto"])
        XCTAssertEqual(opts?["RequireAcceptReason"] as? Bool, true)
        XCTAssertEqual(opts?["RequireRejectReason"] as? Bool, true)
        XCTAssertEqual(opts?["PushNotificationUrl"] as? String, "https://myserver.com/webhook")
    }
}
