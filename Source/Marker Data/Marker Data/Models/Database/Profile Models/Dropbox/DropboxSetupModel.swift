//
//  DropboxSetupModel.swift
//  Marker Data
//
//  Created by Milán Várady on 08/02/2024.
//

import Foundation
import OSLog
import EonilFSEvents

class DropboxSetupModel: ObservableObject {
    @Published var setupComplete: Bool = false
    @Published var authURL: URL? = nil
    @Published var authRequestStatus: AirtableAuthRequestStatus = .notInitiated
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DropboxSetupModel")
    
    init() {
        self.setupComplete = self.isRefreshTokenDefined()
    }
    
    /// Save and register Dropbox app key
    /// - returns: authentication URL
    func saveAppKeyAndLaunchTerminal(_ appKey: String) async throws {
        await MainActor.run {
            self.authRequestStatus = .inProgress
        }
        
        try await self.saveAppKeyToDisk(appKey)
        
        try launchTerminal()
        
        try await MainActor.run {
            // Monitor file for changes
            try EonilFSEvents.startWatching(
                paths: [URL.dropboxTokenJSON.path(percentEncoded: false)],
                for: ObjectIdentifier(self),
                with: { event in
                    guard let flags = event.flag else {
                        return
                    }
                    
                    if flags.contains(.itemModified) {
                        if self.isRefreshTokenDefined() {
                            self.authRequestStatus = .success
                            self.setupComplete = true
                        }
                    }
                })
        }
    }
    
    private func saveAppKeyToDisk(_ appKey: String) async throws {
        let dropboxInfo = DropboxInfo(appKey: appKey, refreshToken: "")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(dropboxInfo)
        
        try data.write(to: URL.dropboxTokenJSON)
    }
    
    private func launchTerminal() throws {
        guard let airliftURL = Bundle.main.url(forResource: "airlift", withExtension: nil) else {
            Self.logger.error("Failed to upload to Notion: csv2notion executable not found")
            throw DatabaseUploadError.csv2notionExecutableNotFound
        }
        
        let executablePath = airliftURL.path(percentEncoded: false)
        let dropboxJSONPath = URL.dropboxTokenJSON.path(percentEncoded: false)
        let logPath = URL.logsFolder
            .appendingPathComponent("airlift_log.txt", conformingTo: .plainText).path(percentEncoded: false)
        
        let scriptSource = """
tell application "Terminal"
    activate
    do script "\\"\(executablePath)\\" --dropbox-token \\"\(dropboxJSONPath)\\" --dropbox-refresh-token --log \\"\(logPath)\\" --verbose"
end tell
"""
        let script = NSAppleScript(source: scriptSource)
        var errorInfo: NSDictionary? = nil
        let result = script?.executeAndReturnError(&errorInfo)
        
        if result == nil {
            Self.logger.error("Failed to launch Terminal. \(errorInfo.debugDescription)")
            throw DropboxError.terminalLaunchError
        }
    }
    
    func isRefreshTokenDefined() -> Bool {
        let decoder = JSONDecoder()
        
        do {
            let data = try Data(contentsOf: URL.dropboxTokenJSON)
            let dropboxInfo = try decoder.decode(DropboxInfo.self, from: data)
            
            return !dropboxInfo.refreshToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } catch {
            Self.logger.error("Failed to decode check JSON: \(error.localizedDescription, privacy: .public)")
            return false
        }
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
    case terminalLaunchError
}
