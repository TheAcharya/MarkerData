import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit
import UniformTypeIdentifiers
import Logging
import LoggingOSLog

final class ExtractionModel: ObservableObject {
    let settings: SettingsContainer
    let databaseManager: DatabaseManager
    
    static let supportedContentTypes: [UTType] = [.fcpxml, .fcpxmld]
    
    /// Controls whether progress UI is shown in the ExtractView
    @Published var showProgressUI = false
    /// Extraction currently is in progress
    @MainActor
    @Published var extractionInProgress = false
    /// External file recieved
    @Published var externalFileRecieved = false
    @Published var externalFileURL: URL? = nil
    /// Extraction exit result/status
    @Published var exportResult: ExportExitStatus = .none
    @Published var completedOutputFolder: URL? = nil
    
    @Published var extractionProgress = ProgressViewModel(taskDescription: "Extract")
    @Published var uploadProgress = ProgressViewModel(taskDescription: "Upload")
    
    public var failedTasks: [ExtractionFailure] = []
    
    // Cancellation
    private var taskGroup: TaskGroup<Void>? = nil
    var uploadProcesses: [Process?] = []
    
//    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ExtractionModel")
    static let logger = Logger(label: Bundle.main.bundleIdentifier!)

    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.settings = settings
        self.databaseManager = databaseManager
        
        // Configure swift-log logging system to use OSLog backend
        LoggingSystem.bootstrap(LoggingOSLog.init)
        
        self.setupEventHandlers()
    }
    
    public func performExtraction(_ urls: [URL]) async {
        func validateExportDestination() throws {
            var isDir : ObjCBool = false
            
            let exportPath: String = settings.store.exportFolderURL?.path(percentEncoded: false) ?? ""
            
            if !FileManager.default.fileExists(atPath: exportPath, isDirectory: &isDir) {
                Self.logger.error("Extract error: Empty or invalid export destination")
                
                throw ExtractError.invalidExportDestination
            }
        }
        
        func prepareExtraction(for urls: [URL]) async {
            Self.logger.notice("Processing files: \(urls.map { $0.path(percentEncoded: false) })")
            
            self.extractionProgress.setProcesses(urls: urls)
            
            // Show extraction progress
            await MainActor.run {
                self.showProgressUI = true
                self.extractionInProgress = true
            }
        }
        
        @Sendable 
        func extractAndUpdateProgress(for url: URL) async throws -> ExportResult? {
            // Get extraction settings
            guard let settings = try? self.settings.store.markersExtractorSettings(fcpxmlFileUrl: url) else {
                throw ExtractError.settingsReadError
            }
            
            let markersExtractorLogger = Logger(label: Bundle.main.bundleIdentifier!, factory: LoggingOSLog.init)
            
            let extractor = MarkersExtractor(settings, logger: markersExtractorLogger)
            
            // Observe progress changes
            let observation = extractor.observe(
                \.progress.fractionCompleted,
                 options: [.old, .new]
            ) { object, change in
                Task {
                    await self.extractionProgress.updateProgress(of: url, to: Int64(change.newValue! * 100))
                }
            }
            
            var exportResult: ExportResult? = nil
            
            do {
                // Do extraction
                exportResult = try await extractor.extract()
            } catch {
                Self.logger.error("Failed to extract: \(error.localizedDescription)")
                await MainActor.run {
                    failedTasks.append(ExtractionFailure(url: url, exitStatus: .failedToExtract, errorMessage: error.localizedDescription))
                }
            }
            
            observation.invalidate()
            
            // Set progress as finished
            await self.extractionProgress.markProcessAsFinished(url: url)
            
            Self.logger.notice("Successfully extracted: \(url.path(percentEncoded: false))")
            
            return exportResult
        }
        
        @Sendable
        func uploadToDatabaseAndTrackProgress(url: URL, exportResult: ExportResult?) async throws {
            // Check if a database profile is set
            guard let databaseProfile = await self.databaseManager.selectedDatabaseProfile else {
                // Skip upload if no database profile is selected
                Self.logger.notice("Skipping upload for: \(url.path(percentEncoded: true))")
                return
            }
            
            guard let jsonURL = exportResult?.jsonManifestPath else {
                Self.logger.error("Failed to upload \(url): missing json URL. Most likely no markers were extracted.")
                throw DatabaseUploadError.missingJsonFile
            }
            
            Self.logger.notice("Upload started")
            
            // Add process to upload progress
            self.uploadProgress.addProcess(url: jsonURL)
            
            // Upload
            try await self.uploadToDatabase(url: jsonURL, databaseProfile: databaseProfile)
            
            Self.logger.notice("Successfully uploaded: \(url.path(percentEncoded: false))")
        }
        
        // MARK: Prepare for extraction
        
        defer {
            self.taskGroup = nil
            self.uploadProcesses.removeAll()
            
            DispatchQueue.main.async {
                self.extractionInProgress = false
            }
        }
        
        Self.logger.notice("Extraction started")
        
        await self.clearProgress()
        
        // Validate export destination
        do {
            try validateExportDestination()
        } catch {
            self.extractionProgress.markasFailed(
                progressMessage: "Empty or invalid export destination",
                alertMessage: "Empty or invalid export destination. Please select one."
            )
            
            return
        }
        
        await prepareExtraction(for: urls)
        
        // MARK: Perform extraction and upload in parallel (in case of multiple files
        
        await withTaskGroup(of: Void.self) { group in
            self.taskGroup = group
            
            for url in urls {
                group.addTask {
                    var exportResult: ExportResult? = nil
                    
                    // Extract
                    do {
                        // Check for cancellation
                        if Task.isCancelled {
                            throw ExtractError.userCancel
                        }
                        
                        exportResult = try await extractAndUpdateProgress(for: url)
                        
                        // If we are only processing one file set completedOutputFolder the the export folder
                        if urls.count == 1 {
                            await MainActor.run { [exportResult] in
                                self.completedOutputFolder = exportResult?.exportFolder
                            }
                        }
                    } catch {
                        await MainActor.run {
                            self.failedTasks.append(
                                ExtractionFailure(url: url, exitStatus: .failedToExtract, errorMessage: error.localizedDescription)
                            )
                        }
                    }
                    
                    // Upload to database (if a database profile is selected)
                    do {
                        // Check for cancellation
                        if Task.isCancelled {
                            throw DatabaseUploadError.userCancel
                        }
                        
                        try await uploadToDatabaseAndTrackProgress(url: url, exportResult: exportResult)
                    } catch {
                        await MainActor.run {
                            self.failedTasks.append(
                                ExtractionFailure(url: url, exitStatus: .failedToUpload, errorMessage: error.localizedDescription)
                            )
                        }
                    }
                }
            }
        }
        
        // MARK: Show result
        await MainActor.run {
            if self.failedTasks.isEmpty {
                // Successful extraction
                Self.logger.notice("All extractions successfull")
                self.exportResult = .success
                
                // Send notification
                NotificationManager.sendNotification(taskFinished: true, title: "All complete")
            } else {
                // Failed extraction
                self.exportResult = .failed
                
                var message = "Failed to complete the following files:"
                for failure in failedTasks {
                    message += "\n\(failure.url.lastPathComponent), reason: \(failure.errorMessage)"
                }

                Self.logger.error("\(message)")
                
                var alertMessage = "Multiple failures. Click \"Show Error Details\" for more information."
                
                // Show error message in case of only one extractoin
                if urls.count == 1 {
                    if let firstFailure = self.failedTasks.first {
                        alertMessage = "Error message: \(firstFailure.errorMessage)"
                    }
                }

                if failedTasks.contains(where: { $0.exitStatus == .failedToExtract }) {
                    self.extractionProgress.markasFailed(
                        progressMessage: "Failed to complete extraction",
                        alertMessage: alertMessage
                    )
                }
                
                if failedTasks.contains(where: { $0.exitStatus == .failedToUpload }) {
                    self.uploadProgress.markasFailed(
                        progressMessage: "Failed to complete upload",
                        alertMessage: alertMessage
                    )
                }
            }
            if self.completedOutputFolder == nil {
                self.completedOutputFolder = settings.store.exportFolderURL
            }
        }
    }
    
    @MainActor
    public func clearProgress() async {
        self.exportResult = .none
        self.completedOutputFolder = nil
        self.failedTasks.removeAll()
        self.extractionProgress.reset()
        self.uploadProgress.reset()
    }
    
    @MainActor
    public func cancelAll() {
        Self.logger.notice("User initiated cancel.")
        Self.logger.notice("Cancelling task group.")
        
        self.taskGroup?.cancelAll()
        
        Self.logger.notice("Cancelling upload processes: \(self.uploadProcesses)")
        
        for process in self.uploadProcesses {
            process?.terminate()
        }
    }
}