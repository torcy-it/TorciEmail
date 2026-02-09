//
//  EmailRepositoryImpl.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 08/02/26.
//

import Foundation

/// Implementazione concreta di EmailRepository
/// Gestisce la comunicazione con l'API e il mapping dei dati
final class EmailRepositoryImpl: EmailRepository {
    
    private let apiService: VaporAPIService
    private let mapper: EviMailMapper.Type
    
    /// Initializer con dependency injection
    /// - Parameters:
    ///   - apiService: Service per le chiamate API (default: shared instance)
    ///   - mapper: Mapper per convertire DTO -> Domain models (default: EviMailMapper)
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
            
            // Mapping da DTO (EviMail) a Domain Model (EmailItem)
            let emails = response.results.map { mapper.map($0) }
            
            print("Repository: Mapped \(emails.count) emails")
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
            
            // Mapping da DTO a Domain Model
            let email = mapper.map(eviMail)
            
            print("Repository: Fetched email \(id)")
            return email
            
        } catch let apiError as APIError {
            throw mapAPIError(apiError)
        } catch {
            throw RepositoryError.unknown
        }
    }
    
    func sendEmail(_ draft: EmailDraft) async throws -> String {
        do {
            // Converti EmailDraft (domain) -> EviMailSubmitRequest (DTO)
            let submitRequest = mapDraftToSubmitRequest(draft)
            
            let response = try await apiService.submitEviMail(submitRequest)
            
            print("Repository: Email sent with ID \(response.eviId)")
            return response.eviId
            
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
    
    /// Converte EmailDraft (domain model) in EviMailSubmitRequest (DTO)
    private func mapDraftToSubmitRequest(_ draft: EmailDraft) -> EviMailSubmitRequest {
        // Map carbon copy
        let carbonCopy: SubmitCarbonCopy? = draft.carbonCopy.map {
            SubmitCarbonCopy(name: $0.name, emailAddress: $0.emailAddress)
        }
        
        // Map options
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
                onlineRetentionPeriod: nil,
                deliveryMode: opts.deliveryMode,
                whatsAppPinPolicy: nil,
                commitmentOptions: opts.commitmentOptions,
                commitmentCommentsAllowed: nil,
                rejectReasons: nil,
                acceptReasons: nil,
                requireRejectReason: nil,
                requireAcceptReason: nil,
                pushNotificationUrl: nil,
                pushNotificationFilter: nil,
                affidavitKinds: nil,
                customLayoutLogoUrl: nil,
                pushNotificationExtraData: nil
            )
        }
        
        // Map attachments (Data -> Base64)
        let attachments: [SubmitAttachment]? = draft.attachments?.map { att in
            SubmitAttachment(
                displayName: att.displayName,
                fileName: att.fileName,
                data: att.data.base64EncodedString(),  // Convert Data to Base64
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
}
