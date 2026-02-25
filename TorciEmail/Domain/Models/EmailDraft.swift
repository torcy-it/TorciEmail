import Foundation

/// Modello per creare una nuova email (domain model)
struct EmailDraft {
    let subject: String
    let body: String
    let issuerName: String
    let recipientName: String?
    let recipientEmail: String
    
    // Optional fields
    let replyTo: String?
    let carbonCopy: [CarbonCopyDraft]?
    let options: EmailOptions?
    let attachments: [AttachmentDraft]?
    
    init(
        subject: String,
        body: String,
        issuerName: String,
        recipientName: String? = nil,
        recipientEmail: String,
        replyTo: String? = nil,
        carbonCopy: [CarbonCopyDraft]? = nil,
        options: EmailOptions? = nil,
        attachments: [AttachmentDraft]? = nil
    ) {
        self.subject = subject
        self.body = body
        self.issuerName = issuerName
        self.recipientName = recipientName
        self.recipientEmail = recipientEmail
        self.replyTo = replyTo
        self.carbonCopy = carbonCopy
        self.options = options
        self.attachments = attachments
    }
}

struct CarbonCopyDraft {
    let name: String
    let emailAddress: String
}

struct EmailOptions {
    let certificationLevel: String?
    let language: String?
    let affidavitLanguage: String?
    let appearance: String?
    let agreementPossibilities: String?
    let allowReasons: Bool
    let acceptReasons: [String]
    let rejectReasons: [String]
    let acceptReasonsRequired: Bool
    let rejectReasonsRequired: Bool
    let affidavitKinds: [String]
    let timeToLive: Int?
    let deliveryMode: String?
    let commitmentOptions: String?
    let pushNotificationUrl: String?
    let costCentre: String?
    
    init(
        certificationLevel: String? = "Advanced",
        language: String? = "en",
        affidavitLanguage: String? = "en",
        appearance: String? = "Certified",
        agreementPossibilities: String? = "Accept",
        allowReasons: Bool = false,
        acceptReasons: [String] = [],
        rejectReasons: [String] = [],
        acceptReasonsRequired: Bool = false,
        rejectReasonsRequired: Bool = false,
        timeToLive: Int? = 10080,
        deliveryMode: String? = "Forward",
        commitmentOptions: String? = "AcceptOrReject",
        affidavitKinds: [String] = [
            "Submitted",
            "SubmittedAdvanced",
            "TransmissionResult",
            "DeliveryResult",
            "Read",
            "Committed",
            "CommittedAdvanced",
            "Closed",
            "ClosedAdvanced",
            "Complete",
            "CompleteAdvanced",
            "OnDemand",
            "Event",
            "Failed"
        ],
        pushNotificationUrl: String? = nil,
        costCentre: String? = nil
    ) {
        self.certificationLevel = certificationLevel
        self.language = language
        self.affidavitLanguage = affidavitLanguage
        self.appearance = appearance
        self.agreementPossibilities = agreementPossibilities
        self.allowReasons = allowReasons
        self.acceptReasons = acceptReasons
        self.rejectReasons = rejectReasons
        self.acceptReasonsRequired = acceptReasonsRequired
        self.rejectReasonsRequired = rejectReasonsRequired
        self.timeToLive = timeToLive
        self.deliveryMode = deliveryMode
        self.commitmentOptions = commitmentOptions
        self.affidavitKinds = affidavitKinds
        self.pushNotificationUrl = pushNotificationUrl
        self.costCentre = costCentre
    }
}


struct AttachmentDraft {
    let displayName: String
    let fileName: String
    let data: Data  // Binary data, non base64
    let mimeType: String
    let contentId: String?
    let contentDescription: String?
    
    init(
        displayName: String,
        fileName: String,
        data: Data,
        mimeType: String,
        contentId: String? = nil,
        contentDescription: String? = nil
    ) {
        self.displayName = displayName
        self.fileName = fileName
        self.data = data
        self.mimeType = mimeType
        self.contentId = contentId
        self.contentDescription = contentDescription
    }
}
