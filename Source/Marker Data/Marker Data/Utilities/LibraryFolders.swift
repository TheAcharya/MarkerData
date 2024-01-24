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
    
    /// Deletes cache older then a month
    public static func deleteOldCache() {
        let directory = URL.FCPExportCacheFolder
        let fileManager = FileManager.default
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        
        do {
            let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentModificationDateKey]
            let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)
            
            for url in directoryContents {
                let resourceValues = try url.resourceValues(forKeys: resourceKeys)
                
                if let isDirectory = resourceValues.isDirectory, isDirectory,
                   let modificationDate = resourceValues.contentModificationDate,
                   modificationDate < oneMonthAgo {
                    Self.logger.notice("Cached file \(url.path(percentEncoded: false)) is older than a month. Deleting it.")
                    try fileManager.removeItem(at: url)
                }
            }
        } catch {
            Self.logger.error("Error while enumerating files \(directory.path): \(error.localizedDescription)")
        }
    }
}
