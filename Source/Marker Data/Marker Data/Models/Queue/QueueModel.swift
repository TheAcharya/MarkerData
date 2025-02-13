//
//  QueueModel.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
class QueueModel: ObservableObject {
    let settings: SettingsContainer
    let databaseManager: DatabaseManager
    
    @Published var queueInstances: [QueueInstance] = []
    @Published var uploadInProgress = false
    
    @AppStorage("deleteFolderAfterUpload") var deleteFolderAfterUpload = false
    @AppStorage("queueAutomaticScanEnabled") var automaticScanEnabled = true

    // Cancellation
    private var taskGroup: TaskGroup<Void>? = nil
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QueueModel")
    
    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.settings = settings
        self.databaseManager = databaseManager
    }
    
    func scanFolder(at url: URL, append: Bool = false) async throws {
        // Skip if upload is in progress
        if self.uploadInProgress {
            return
        }

        var queueInstances: [QueueInstance] = []
        
        // Recursive iteration
        let extractInfoURLs = walkDirectory(at: url, options: [.skipsHiddenFiles, .skipsPackageDescendants]).filter {
            $0.lastPathComponent == "extract_info.json"
        }

        let decoder = JSONDecoder()

        for await extractInfoURL in extractInfoURLs {
            do {
                let data = try Data(contentsOf: extractInfoURL)
                let extractInfo = try decoder.decode(ExtractInfo.self, from: data)

                // Add queue instance
                queueInstances.append(
                    QueueInstance(
                        extractInfo: extractInfo,
                        folderURL: extractInfoURL.deletingLastPathComponent(),
                        databaseProfiles: databaseManager.profiles
                    )
                )
            } catch {
                Self.logger.error("Failed to decode \(extractInfoURL.path(percentEncoded: false)): \(error.localizedDescription, privacy: .public)")
                continue
            }
        }

        let queueInstancesSorted = queueInstances
            .sorted(by: { $0.extractInfo.creationDate > $1.extractInfo.creationDate })

        if append {
            self.queueInstances.append(contentsOf: queueInstancesSorted)
        } else {
            self.queueInstances = queueInstancesSorted
        }
    }

    func scanExportFolder() async throws {
        if !automaticScanEnabled {
            return
        }

        guard let exportFolder = self.settings.store.exportFolderURL else {
            Self.logger.error("Missing output directory")
            throw QueueError.missingOutputDirectory
        }

        try await self.scanFolder(at: exportFolder)
    }

    func upload() async throws {
        defer {
            self.uploadInProgress = false
            self.taskGroup = nil
        }

        self.uploadInProgress = true
        
        await withTaskGroup(of: Void.self) { group in
            self.taskGroup = group
            
            for queueInstance in self.queueInstances {
                group.addTask {
                    do {
                        try await queueInstance.upload()
                        
                        if await self.deleteFolderAfterUpload && !Task.isCancelled {
                            await queueInstance.deleteFolder()
                        }
                    } catch {
                        await MainActor.run {
                            queueInstance.status = .failed
                        }

                        await Self.logger.error("Failed to upload \(queueInstance.name)")
                    }
                }
            }
        }
    }

    func cancelUpload() {
        self.taskGroup?.cancelAll()
        
        for queueInstance in queueInstances {
            queueInstance.uploader.cancelAll()
        }
        
        self.uploadInProgress = false
    }

    /// Filters out queue instaces which no loger point to existing files
    func filterMissing() async {
        self.queueInstances = self.queueInstances.filter {
            $0.extractInfo.jsonURL.fileExists
        }
    }

    func clear() {
        self.queueInstances.removeAll()
        self.automaticScanEnabled = false
    }

    func performDrop(urls: [URL]) {
        // Clear current queue instances
        self.queueInstances.removeAll()

        for url in urls {
            // Check file type
            if url.hasDirectoryPath {
                Task { [weak self] in
                    try await self?.scanFolder(at: url, append: true)
                }
            } else {
                Self.logger.notice("Skipping file \(url.path(percentEncoded: false)). Not supported.")
            }
        }

        self.automaticScanEnabled = false
    }
}
