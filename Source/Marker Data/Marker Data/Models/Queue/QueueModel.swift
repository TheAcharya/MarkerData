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
    
    public func scanFolder(at url: URL, append: Bool = false) async throws {
        @Sendable
        func walkDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions) -> AsyncStream<URL> {
            AsyncStream { continuation in
                Task {
                    let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)

                    while let fileURL = enumerator?.nextObject() as? URL {
                        continuation.yield(fileURL)
                    }

                    continuation.finish()
                }
            }
        }

        // Skip if upload is in progress
        if await self.uploadInProgress {
            return
        }

        let fileManager = FileManager.default

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
                await queueInstances.append(
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

        await MainActor.run { [queueInstances] in
            let queueInstancesSorted = queueInstances
                .sorted(by: { $0.extractInfo.creationDate > $1.extractInfo.creationDate })

            if append {
                self.queueInstances.append(contentsOf: queueInstancesSorted)
            } else {
                self.queueInstances = queueInstancesSorted
            }
        }
    }

    public func scanExportFolder() async throws {
        guard let exportFolder = self.settings.store.exportFolderURL else {
            Self.logger.error("Missing output directory")
            throw QueueError.missingOutputDirectory
        }

        try await self.scanFolder(at: exportFolder)
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
                            await queueInstance.deleteFolder()
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

    /// Filters out queue instaces which no loger point to existing files
    @MainActor
    public func filterMissing() async {
        self.queueInstances = self.queueInstances.filter {
            $0.extractInfo.jsonURL.fileExists
        }
    }
}
