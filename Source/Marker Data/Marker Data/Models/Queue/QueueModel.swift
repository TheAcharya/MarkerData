//
//  QueueModel.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import Foundation
import OSLog

class QueueModel: ObservableObject {
    let settings: SettingsContainer
    let databaseManager: DatabaseManager
    
    @Published var records: [ExtractInfo] = []
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QueueModel")
    
    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.settings = settings
        self.databaseManager = databaseManager
    }
    
    public func scanExportFolder() async throws {
        guard let directory = self.settings.store.exportFolderURL else {
            Self.logger.error("Missing output directory")
            throw QueueError.missingOutputDirectory
        }
        let fileManager = FileManager.default
        
        let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        
        var records: [ExtractInfo] = []
        
        // Loop through directories in export folder
        for url in directoryContents {
            let infoFile = url.appendingPathComponent("extract_info", conformingTo: .json)
            
            if infoFile.fileExists {
                let decoder = JSONDecoder()
                
                do {
                    let data = try Data(contentsOf: infoFile)
                    let decoded = try decoder.decode(ExtractInfo.self, from: data)
                    
                    // Add record
                    records.append(decoded)
                } catch {
                    Self.logger.error("Failed to decode \(infoFile.path(percentEncoded: false)): \(error.localizedDescription, privacy: .public)")
                    continue
                }
            }
        }
        
        await MainActor.run { [records] in
            self.records = records
        }
    }
}
