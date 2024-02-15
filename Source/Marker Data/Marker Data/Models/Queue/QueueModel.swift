//
//  QueueModel.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import Foundation
import SwiftUI
import OSLog

class QueueModel: ObservableObject {
    let settings: SettingsContainer
    let databaseManager: DatabaseManager
    @Published var queueInstances: [QueueInstance] = []
    @MainActor
    @Published var uploadInProgress = false
    @AppStorage("deleteFolderAfterUpload") var deleteFolderAfterUpload = false
    
    // Cancellation
    private var taskGroup: TaskGroup<Void>? = nil
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QueueModel")
    
    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.settings = settings
        self.databaseManager = databaseManager
    }
    
    public func scanExportFolder() async throws {
        // Skip if upload is in progress
        if await self.uploadInProgress {
            return
        }
        
        guard let directory = self.settings.store.exportFolderURL else {
            Self.logger.error("Missing output directory")
            throw QueueError.missingOutputDirectory
        }
        let fileManager = FileManager.default
        
        let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
        
        var queueInstances: [QueueInstance] = []
        
        // Loop through directories in export folder
        for url in directoryContents {
            let infoFile = url.appendingPathComponent("extract_info", conformingTo: .json)
            
            if infoFile.fileExists {
                let decoder = JSONDecoder()
                
                do {
                    let data = try Data(contentsOf: infoFile)
                    let extractInfo = try decoder.decode(ExtractInfo.self, from: data)
                    
                    // Add record
                    await queueInstances.append(
                        QueueInstance(
                            extractInfo: extractInfo,
                            folderURL: url,
                            databaseProfiles: databaseManager.profiles
                        )
                    )
                } catch {
                    Self.logger.error("Failed to decode \(infoFile.path(percentEncoded: false)): \(error.localizedDescription, privacy: .public)")
                    continue
                }
            }
        }
        
        await MainActor.run { [queueInstances] in
            self.queueInstances = queueInstances
                .sorted(by: { $0.extractInfo.creationDate > $1.extractInfo.creationDate })
        }
    }
    
    public func upload() async throws {
        defer {
            Task {
                await MainActor.run {
                    self.uploadInProgress = false
                    self.taskGroup = nil
                }
            }
        }
        
        await MainActor.run {
            self.uploadInProgress = true
        }
        
        await withTaskGroup(of: Void.self) { group in
            self.taskGroup = group
            
            for queueInstance in self.queueInstances {
                group.addTask {
                    do {
                        try await queueInstance.upload()
                        
                        if self.deleteFolderAfterUpload && !Task.isCancelled {
                            queueInstance.deleteFolder()
                        }
                    } catch {
                        await MainActor.run {
                            queueInstance.status = .failed
                        }
                        
                        Self.logger.error("Failed to upload \(queueInstance.name)")
                    }
                }
            }
        }
    }
    
    @MainActor
    public func cancelUpload() {
        self.taskGroup?.cancelAll()
        
        for queueInstance in queueInstances {
            queueInstance.uploader.cancelAll()
        }
        
        self.uploadInProgress = false
    }
}
