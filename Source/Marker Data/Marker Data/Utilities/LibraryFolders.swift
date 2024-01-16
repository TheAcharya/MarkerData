//
//  LibraryFolders.swift
//  Marker Data
//
//  Created by Milán Várady on 15/01/2024.
//

import Foundation
import OSLog

/// Manages the Library folders (~/Library/Application Support/Marker Data)
struct LibraryFolders {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "LibaryFolders")
    
    /// Checks if the nescessary library folders are present, and creates them if not
    public static func checkAndCreateMissing() async throws {
        let foldersToCheck: [URL] = [
            URL.markerDataLibraryFolder,
            URL.configurationsFolder,
            URL.databaseFolder,
            URL.databaseProfilesFolder,
            URL.logsFolder,
            URL.FCPTemporaryExportFolder
        ]
        
        let fileManager = FileManager.default
        
        for folder in foldersToCheck {
            if !folder.fileExists {
                Self.logger.notice("Library folder: \(folder.path(percentEncoded: false)) doesn't exist. Attempting to create it.")
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        }
        
        Self.logger.info("All Library folders OK")
    }
}
