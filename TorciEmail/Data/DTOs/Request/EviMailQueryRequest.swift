//
//  EviMailQueryRequest.swift
//  TorciEmail
//
//  DTO richiesta query EviMail.
//  Supporta flag di inclusione blob allegati/certificati.
//


/// Parametri di query verso endpoint ricerca EviMail.
struct EviMailQueryRequest: Codable {
    let limit: Int
    let offset: Int?
    let withUniqueIds: [String]?
    let includeAffidavits: Bool?
    let includeAttachments: Bool?
    let includeAttachmentBlobs: Bool?
    let includeAffidavitBlobs: Bool?
    
    enum CodingKeys: String, CodingKey {
        case limit, offset
        case withUniqueIds = "WithUniqueIds"
        case includeAffidavits = "IncludeAffidavits"
        case includeAttachments = "IncludeAttachments"
        case includeAttachmentBlobs = "IncludeAttachmentBlobs"
        case includeAffidavitBlobs = "IncludeAffidavitBlobs"
    }
    
    /// Encodifica solo i campi opzionali valorizzati per ridurre payload.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(limit, forKey: .limit)
        if let offset = offset {
            try container.encode(offset, forKey: .offset)
        }
        if let withUniqueIds = withUniqueIds {
            try container.encode(withUniqueIds, forKey: .withUniqueIds)
        }
        if let includeAffidavits = includeAffidavits {
            try container.encode(includeAffidavits, forKey: .includeAffidavits)
        }
        if let includeAttachments = includeAttachments {
            try container.encode(includeAttachments, forKey: .includeAttachments)
        }
        if let includeAttachmentBlobs = includeAttachmentBlobs {
            try container.encode(includeAttachmentBlobs, forKey: .includeAttachmentBlobs)
        }
        if let includeAffidavitBlobs = includeAffidavitBlobs {
            try container.encode(includeAffidavitBlobs, forKey: .includeAffidavitBlobs)
        }
    }
}
