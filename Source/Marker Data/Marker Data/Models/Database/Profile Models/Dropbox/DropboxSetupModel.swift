//
//  DropboxSetupModel.swift
//  Marker Data
//
//  Created by Milán Várady on 08/02/2024.
//

import Foundation
import AppKit
import OSLog

@MainActor
class DropboxSetupModel: ObservableObject {
    @Published var setupComplete: Bool = false
    @Published var authURL: URL? = nil
    @Published var authRequestStatus: AirtableAuthRequestStatus = .notInitiated
    
    private let watcher = FileWatcher(url: .dropboxTokenJSON)
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DropboxSetupModel")
    
    init() {
        self.setupComplete = self.isRefreshTokenDefined()
    }
    
    /// Save and register Dropbox app key
    /// - returns: authentication URL
    func saveAppKeyAndLaunchTerminal(_ appKey: String) async throws {
        self.authRequestStatus = .inProgress
        
        try await self.saveAppKeyToDisk(appKey)
        
        try launchTerminal()

        // Monitor file for changes
        await startMonitoring()
    }
    
    private func saveAppKeyToDisk(_ appKey: String) async throws {
        let dropboxInfo = DropboxInfo(appKey: appKey, refreshToken: "")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(dropboxInfo)
        
        try data.write(to: URL.dropboxTokenJSON)
    }
    
    /// Launches Terminal with the airlift Dropbox auth command using a .command file,
    /// avoiding NSAppleScript which requires Apple Events permissions
    /// that macOS Tahoe restricts.
    private func launchTerminal() throws {
        guard let airliftURL = Bundle.main.url(forResource: "airlift", withExtension: nil) else {
            Self.logger.error("Failed to find airlift executable")
            throw DatabaseUploadError.csv2notionExecutableNotFound
        }
        
        let executablePath = airliftURL.path(percentEncoded: false)
        let dropboxJSONPath = URL.dropboxTokenJSON.path(percentEncoded: false)
        let logPath = URL.logsFolder
            .appendingPathComponent("airlift_log.txt", conformingTo: .plainText).path(percentEncoded: false)
        
        let scriptContent = """
        #!/bin/bash
        "\(executablePath)" --dropbox-token "\(dropboxJSONPath)" --dropbox-refresh-token --log "\(logPath)" --verbose
        """
        
        let scriptURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("marker_data_dropbox_setup.command")
        
        try scriptContent.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o755],
            ofItemAtPath: scriptURL.path(percentEncoded: false)
        )
        
        if !NSWorkspace.shared.open(scriptURL) {
            Self.logger.error("Failed to open .command file in Terminal")
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
    
    private func startMonitoring() async {
        try? await watcher.startWatching {
            Task { @MainActor in
                if self.isRefreshTokenDefined() {
                    self.authRequestStatus = .success
                    self.setupComplete = true
                }
            }
        }
    }
}

enum AirtableAuthRequestStatus {
    case notInitiated
    case inProgress
    case success
}

enum DropboxError: Error, LocalizedError {
    case airliftGetURLError
    case failedToFindURL
    case terminalLaunchError

    var errorDescription: String? {
        switch self {
        case .airliftGetURLError:
            return "Failed to get airlift URL."
        case .failedToFindURL:
            return "Failed to find URL."
        case .terminalLaunchError:
            return "Failed to launch Terminal. Please ensure Marker Data has permission to open Terminal in System Settings > Privacy & Security."
        }
    }
}
