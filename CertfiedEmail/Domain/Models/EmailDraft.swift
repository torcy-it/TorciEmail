import Foundation

/// Modello di dominio usato per costruire una richiesta di invio EviMail.
struct EmailDraft {
    let subject: String
    let body: String
    let issuerName: String
    let recipientName: String? = nil
    let recipientEmail: String
    
    /// Campi opzionali della bozza.
    let replyTo: String? = nil
    let carbonCopy: [CarbonCopyDraft]? = nil
    let options: EmailOptions? = nil
    let attachments: [AttachmentDraft]? = nil
}

struct CarbonCopyDraft {
    let name: String
    let emailAddress: String
}

struct EmailOptions {
    let certificationLevel: String? = "Advanced"
    let language: String? = "en"
    let affidavitLanguage: String? = "en"
    let appearance: String? = "Certified"
    let agreementPossibilities: String? = "Accept"
    let allowReasons: Bool = false
    let acceptReasons: [String] = []
    let rejectReasons: [String] = []
    let acceptReasonsRequired: Bool = false
    let rejectReasonsRequired: Bool = false
    let affidavitKinds: [String] = [
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
    ]
    let timeToLive: Int? = 10080
    let deliveryMode: String? = "Forward"
    let commitmentOptions: String? = "AcceptOrReject"
    let pushNotificationUrl: String? = nil
    let costCentre: String? = nil
}


/// Allegato da inviare in submit.
struct AttachmentDraft {
    let displayName: String
    let fileName: String
    /// Dati binari raw del file. Il mapping DTO li converte in base64.
    let data: Data
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
