//
//  FileStorageService.swift
//  CertfiedEmail
//
//  Created by Cursor Refactor on 25/02/26.
//

import Foundation

/// Astrazione per il salvataggio di file scaricati (allegati, affidavits) nello
/// spazio Documenti dell'app, così da poterli condividere o visualizzare.
protocol FileStorageService {
    /// Salva i dati in un file nella cartella Documents.
    /// - Parameters:
    ///   - data: Contenuto binario del file.
    ///   - fileName: Nome file suggerito (inclusa estensione).
    /// - Returns: URL del file salvato.
    func saveToDocuments(data: Data, fileName: String) throws -> URL
}

final class DefaultFileStorageService: FileStorageService {
    
    func saveToDocuments(data: Data, fileName: String) throws -> URL {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw RepositoryError.invalidData
        }
        
        let sanitizedName = fileName.isEmpty ? "downloaded-file" : fileName
        let targetURL = documentsURL.appendingPathComponent(sanitizedName)
        
        // Se esiste già, sovrascriviamo
        if fileManager.fileExists(atPath: targetURL.path) {
            try fileManager.removeItem(at: targetURL)
        }
        
        try data.write(to: targetURL, options: .atomic)
        return targetURL
    }
}

