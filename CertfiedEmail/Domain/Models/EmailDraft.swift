import Foundation

/// Modello di dominio usato per costruire una richiesta di invio EviMail.
struct EmailDraft {
    let subject: String
    let body: String
    let issuerName: String
    var recipientName: String? = nil
    let recipientEmail: String
    
    /// Campi opzionali della bozza.
    var replyTo: String? = nil
    var carbonCopy: [CarbonCopyDraft]? = nil
    var options: EmailOptions? = nil
    var attachments: [AttachmentDraft]? = nil
}

struct CarbonCopyDraft {
    let name: String
    let emailAddress: String
}

struct EmailOptions {
    var certificationLevel: String? = "Advanced"
    var language: String? = "en"
    var affidavitLanguage: String? = "en"
    var appearance: String? = "Certified"
    var agreementPossibilities: String? = "Accept"
    var allowReasons: Bool = false
    var acceptReasons: [String] = []
    var rejectReasons: [String] = []
    var acceptReasonsRequired: Bool = false
    var rejectReasonsRequired: Bool = false
    var affidavitKinds: [String] = [
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
    var timeToLive: Int? = 10080
    var deliveryMode: String? = "Forward"
    var commitmentOptions: String? = "AcceptOrReject"
    var pushNotificationUrl: String? = nil
    var costCentre: String? = nil
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
