//
//  EmailRepositoryImpl.swift
//  TorciEmail
//
//  Implementazione repository email lato client.
//  Traduce operazioni di dominio in chiamate API e mappatura DTO.
//

import Foundation

/// Implementazione concreta di EmailRepository
/// Gestisce la comunicazione con l'API e la mappatura dei dati.
final class EmailRepositoryImpl: EmailRepository {
    
    private let apiService: VaporAPIService
    private let mapper: EviMailMapper.Type
    
    /// Inizializzatore con dependency injection.
    /// - Parameters:
    ///   - apiService: Servizio API (predefinito: istanza condivisa).
    ///   - mapper: Mapper DTO -> dominio (predefinito: `EviMailMapper`).
    init(
        apiService: VaporAPIService = .shared,
        mapper: EviMailMapper.Type = EviMailMapper.self
    ) {
        self.apiService = apiService
        self.mapper = mapper
    }
    
    // MARK: - EmailRepository
    
    func getAllEmails() async throws -> [EmailItem] {
        do {
            let response = try await apiService.queryAllEviMails()
            
            // Mappatura da DTO (EviMail) a modello di dominio (EmailItem)
            let emails = response.results.map { mapper.map($0) }
            return emails
            
        } catch let apiError as APIError {
            // Converti APIError in RepositoryError
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    func getEmail(id: String) async throws -> EmailItem {
        do {
            let eviMail = try await apiService.getEviMail(id: id)
            
            // Mappatura da DTO a modello di dominio
            let email = mapper.map(eviMail)
            return email
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    func sendEmail(_ draft: EmailDraft) async throws -> String {
        do {
            // Converte EmailDraft (dominio) in EviMailSubmitRequest (DTO)
            let submitRequest = mapDraftToSubmitRequest(draft)
            let response = try await apiService.submitEviMail(submitRequest)
            return response.eviId
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    /// Invia una bozza con allegato file locale in multipart/form-data.
    /// - Parameters:
    ///   - draft: Bozza email da inviare.
    ///   - fileURL: URL locale del file.
    ///   - fileName: Nome file opzionale.
    /// - Returns: Identificativo EviMail creato.
    func sendEmailWithAttachment(
        _ draft: EmailDraft,
        fileURL: URL,
        fileName: String?
    ) async throws -> String {
        // Validazione file lato client: dimensione e tipo
        let maxSizeBytes = 10 * 1024 * 1024 // 10 MB
        let allowedExtensions = ["pdf", "doc", "docx", "jpg", "jpeg", "png", "zip"]
        
        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey, .nameKey])
        guard resourceValues.isRegularFile == true else {
            throw RepositoryError.invalidData
        }
        
        if let size = resourceValues.fileSize, size > maxSizeBytes {
            throw RepositoryError.fileTooLarge
        }
        
        let ext = fileURL.pathExtension.lowercased()
        guard allowedExtensions.contains(ext) else {
            throw RepositoryError.unsupportedFileType
        }
        
        let data = try Data(contentsOf: fileURL)
        let resolvedFileName = fileName ?? resourceValues.name ?? "attachment.\(ext)"
        let mimeType = mimeTypeForExtension(ext)
        
        do {
            let submitRequest = mapDraftToSubmitRequest(draft)
            
            // Prepara corpo multipart (JSON + file)
            let boundary = "Boundary-\(UUID().uuidString)"
            let bodyData = try buildMultipartBody(
                boundary: boundary,
                jsonRequest: submitRequest,
                fileFieldName: "attachment",
                fileName: resolvedFileName,
                fileMimeType: mimeType,
                fileData: data
            )
            
            let responseData = try await apiService.sendMultipart(
                endpoint: "/evimails/submit",
                bodyData: bodyData,
                contentType: "multipart/form-data; boundary=\(boundary)",
                requiresAuth: true
            )
            
            let decoded = try JSONDecoder().decode(EviMailSubmitResponse.self, from: responseData)
            return decoded.eviId
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    // MARK: - Private Helpers
    
    /// Mappa APIError in RepositoryError (astrazione dell'errore API)
    private func mapAPIError(_ error: APIError) -> RepositoryError {
        switch error {
        case .unauthorized:
            return .unauthorized
        case .httpError(404, _):
            return .emailNotFound
        case .httpError(413, _):
            return .fileTooLarge
        case .httpError(_, let message):
            return .serverError(message: message ?? "Errore del server")
        case .networkError:
            return .networkError
        case .decodingError:
            return .invalidData
        default:
            return .unknown
        }
    }
    
    /// Converte la bozza di dominio nel DTO richiesto dall'endpoint submit.
    func mapDraftToSubmitRequest(_ draft: EmailDraft) -> EviMailSubmitRequest {
        // Mappa carbon copy
        let carbonCopy: [SubmitCarbonCopy]? = draft.carbonCopy?.map {
            SubmitCarbonCopy(name: $0.name, emailAddress: $0.emailAddress)
        }
        
        // Mappa opzioni
        let options: SubmitOptions? = draft.options.map { opts in
            SubmitOptions(
                costCentre: opts.costCentre,
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
        
        // Mappa allegati
        let attachments: [SubmitAttachment]? = draft.attachments?.map { att in
            SubmitAttachment(
                displayName: att.displayName,
                fileName: att.fileName,
                data: att.data.base64EncodedString(),
                mimeType: att.mimeType,
                contentId: att.contentId,
                contentDescription: att.contentDescription
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
            attachments: attachments
        )
    }
    
    /// Mappa estensione file al relativo MIME type.
    private func mimeTypeForExtension(_ ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "zip": return "application/zip"
        default: return "application/octet-stream"
        }
    }
    
    /// Costruisce il body multipart contenente payload JSON e allegato binario.
    private func buildMultipartBody<T: Encodable>(
        boundary: String,
        jsonRequest: T,
        fileFieldName: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) throws -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        
        // Parte JSON
        let jsonData = try JSONEncoder().encode(jsonRequest)
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"payload\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: application/json\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(jsonData)
        body.append(lineBreak.data(using: .utf8)!)
        
        // Parte file
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: \(fileMimeType)\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(fileData)
        body.append(lineBreak.data(using: .utf8)!)
        
        // Chiusura
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        return body
    }
    
}
