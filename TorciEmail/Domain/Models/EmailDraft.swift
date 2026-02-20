import Foundation

/// Modello per creare una nuova email (domain model)
struct EmailDraft {
    let subject: String
    let body: String
    let issuerName: String
    let recipientName: String
    let recipientEmail: String
    
    // Optional fields
    let replyTo: String?
    let carbonCopy: CarbonCopyDraft?
    let options: EmailOptions?
    let attachments: [AttachmentDraft]?
    
    init(
        subject: String,
        body: String,
        issuerName: String,
        recipientName: String,
        recipientEmail: String,
        replyTo: String? = nil,
        carbonCopy: CarbonCopyDraft? = nil,
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
    let timeToLive: Int?
    let deliveryMode: String?
    let commitmentOptions: String?
    
    init(
        certificationLevel: String? = "Advanced",
        language: String? = "en",
        affidavitLanguage: String? = "en",
        timeToLive: Int? = nil,
        deliveryMode: String? = nil,
        commitmentOptions: String? = nil
    ) {
        self.certificationLevel = certificationLevel
        self.language = language
        self.affidavitLanguage = affidavitLanguage
        self.timeToLive = timeToLive
        self.deliveryMode = deliveryMode
        self.commitmentOptions = commitmentOptions
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
