//
//  DropboxSetupModel.swift
//  Marker Data
//
//  Created by Milán Várady on 08/02/2024.
//

import Foundation
import OSLog

class DropboxSetupModel: ObservableObject {
    @Published var setupComplete: Bool = false
    @Published var authURL: URL? = nil
    @Published var authRequestStatus: AirtableAuthRequestStatus = .notInitiated
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DropboxSetupModel")
    
    /// Save and register Dropbox app key
    /// - returns: authentication URL
    func saveAndRegisterAppKey(_ appKey: String) async throws {
        await MainActor.run {
            self.authRequestStatus = .inProgress
        }
        
        try await self.saveAppKeyToDisk(appKey)
        
        self.authURL = try await self.getAuthURL()
        
        await MainActor.run {
            self.authRequestStatus = .success
        }
    }
    
    private func saveAppKeyToDisk(_ appKey: String) async throws {
        let dropboxInfo = DropboxInfo(appKey: appKey, refreshToken: "")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(dropboxInfo)
        
        try data.write(to: URL.dropboxTokenJSON)
    }
    
    private func getAuthURL() async throws -> URL {
        guard let airliftURL = Bundle.main.url(forResource: "csv2notion_neo", withExtension: nil) else {
            Self.logger.error("Failed to upload to Notion: csv2notion executable not found")
            throw DatabaseUploadError.csv2notionExecutableNotFound
        }
        
        let executablePath = airliftURL.path(percentEncoded: false).quoted
        
        let logPath = URL.logsFolder
            .appendingPathComponent("airlift_log.txt", conformingTo: .plainText).path(percentEncoded: false)
        
        let arguments: [String] = [
            "--dropbox-token", URL.dropboxTokenJSON.path(percentEncoded: false).quoted,
            "--dropbox-refresh-token",
            "--log", logPath,
            "--verbose"
        ]
        
        let result = await shell("\(executablePath) \(arguments.joined(separator: " "))")
        
        if result.didFail {
            Self.logger.error("Failed to get URL from airlift: \(result.output, privacy: .public)")
            throw DropboxError.airliftGetURLError
        }
        
        let urlRegex = /(Go to: ).*/
        
        guard let match = result.output.firstMatch(of: urlRegex),
              let url = URL(string: match.1.string) else {
            throw DropboxError.failedToFindURL
        }
        
        return url
    }
}

enum AirtableAuthRequestStatus {
    case notInitiated
    case inProgress
    case success
}

enum DropboxError: Error {
    case airliftGetURLError
    case failedToFindURL
}
