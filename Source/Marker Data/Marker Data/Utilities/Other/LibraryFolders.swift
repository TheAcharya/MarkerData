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
            URL.databaseProfilesFolder,
            URL.notionProfilesFolder,
            URL.airtableProfilesFolder,
            URL.dropboxFolder,
            URL.logsFolder,
            URL.FCPExportCacheFolder
        ]
        
        let fileManager = FileManager.default
        
        for folder in foldersToCheck {
            if !folder.fileExists {
                Self.logger.notice("Library folder: \(folder.path(percentEncoded: false)) doesn't exist. Attempting to create it.")
                try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        }
        
        Self.deleteOldCache()
        
        Self.logger.info("All Library folders OK")
    }
    
    public static func deleteCache() {
        let fileManager = FileManager.default
        
        Self.logger.info("Deleting cache")
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: URL.FCPExportCacheFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for url in contents {
                try fileManager.removeItem(at: url)
            }
        } catch {
            Self.logger.error("Failed to delete cache: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    /// Deletes cache older then a month
    public static func deleteOldCache() {
        let directory = URL.FCPExportCacheFolder
        let fileManager = FileManager.default
        guard let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else {
            return
        }

        do {
            let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey]
            let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)
            
            for url in directoryContents {
                let resourceValues = try url.resourceValues(forKeys: resourceKeys)
                
                if let modificationDate = resourceValues.contentModificationDate,
                   modificationDate < oneMonthAgo {
                    Self.logger.notice("Cached file \(url.path(percentEncoded: false)) is older than a month. Deleting it.")
                    try fileManager.removeItem(at: url)
                }
            }
        } catch {
            Self.logger.error("Failed to delete old cache: \(error.localizedDescription, privacy: .public)")
        }
    }
}
