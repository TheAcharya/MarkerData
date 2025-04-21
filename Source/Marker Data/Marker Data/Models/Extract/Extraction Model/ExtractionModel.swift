import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit
import UniformTypeIdentifiers
import Logging
import LoggingOSLog
import DockProgress

@MainActor
final class ExtractionModel: ObservableObject, Sendable {
    let settings: SettingsContainer
    let databaseManager: DatabaseManager
    
    var databaseUploader = DatabaseUploader()
    
    static let supportedContentTypes: [UTType] = [.fcpxml, .fcpxmld]
    
    /// Controls whether progress UI is shown in the ExtractView
    @Published var showProgressUI = false
    /// Extraction currently is in progress
    @Published var extractionInProgress = false
    /// External file recieved
    @Published var externalFileRecieved = false
    @Published var externalFileURL: URL? = nil
    /// Extraction exit result/status
    @Published var exportResult: ExportExitStatus = .none
    @Published var completedOutputFolder: URL? = nil
    
    @Published var extractionProgress = ProgressViewModel(taskDescription: "Extract", taskIcon: "gearshape.2")
    
    public var failedTasks: [ExtractionFailure] = []
    
    // Cancellation
    private var extractionTask: Task<Void, Never>? = nil

    static let logger = Logger(label: Bundle.main.bundleIdentifier!)

    static let loggingHandler: @Sendable (String) -> any LogHandler = { label in
        LoggingOSLog(label: label)
    }

    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.settings = settings
        self.databaseManager = databaseManager
        
        // Configure swift-log logging system to use OSLog backend
        LoggingSystem.bootstrap(Self.loggingHandler)
        
        self.setupEventHandlers()
    }

    func startExtraction(for urls: [URL]) {
        let task = Task {
            await self.performExtraction(urls)
            self.extractionTask = nil
        }

        self.extractionTask = task
    }

    private func performExtraction(_ urls: [URL]) async {
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
            self.showProgressUI = true
            self.extractionInProgress = true
        }

        func extractAndUpdateProgress(for url: URL) async throws -> ExportResult? {
            // Get extraction settings
            let settings = try self.settings.store.markersExtractorSettings(fcpxmlFileUrl: url)
            
            let markersExtractorLogger = Logger(label: Bundle.main.bundleIdentifier!, factory: LoggingOSLog.init)
            
            let extractor = MarkersExtractor(settings: settings, logger: markersExtractorLogger)
            
            // Observe progress changes
            let observation = await extractor.progress.observe(
                \.fractionCompleted,
                 options: [.old, .new]
            ) { object, change in
                if let newValue = change.newValue {
                    Task {
                        await self.extractionProgress.updateProgress(of: url, to: Int64(newValue * 100))
                    }
                }
            }

            var exportResult: ExportResult? = nil
            
            do {
                // Do extraction
                exportResult = try await extractor.extract()
            } catch {
                Self.logger.error("Failed to extract: \(error.localizedDescription)")
                failedTasks.append(ExtractionFailure(url: url, exitStatus: .failedToExtract, errorMessage: error.localizedDescription))
            }
            
            observation.invalidate()

            guard let exportResult = exportResult else {
                throw ExtractError.exportResultisNil
            }

            // Save extraction info JSON
            let extractInfo = ExtractInfo(exportResult: exportResult)
            let jsonURL = exportResult.exportFolder.appendingPathComponent("extract_info", conformingTo: .json)

            try extractInfo?.save(to: jsonURL)

            // Add color palette
            let swatchSettings = self.settings.store.colorSwatchSettings

            if swatchSettings.enableSwatch {
                Self.logger.notice("Color palette enabled. Calculating dominant colors.")

                // Update progress message and icon
                self.extractionProgress.reset(taskDescription: "Analysing swatch", taskIcon: "swatchpalette")

                await ColorPaletteRenderer.render(
                    exportResult: exportResult,
                    swatchSettings: swatchSettings,
                    progress: extractionProgress
                )

                Self.logger.notice("Color palette render done.")
            }

            // Set progress as finished
            await self.extractionProgress.markProcessAsFinished(url: url)
            
            Self.logger.notice("Successfully extracted: \(url.path(percentEncoded: false))")

            return exportResult
        }

        func uploadToDatabaseAndTrackProgress(url: URL, exportResult: ExportResult?) async throws {
            // Check if a database profile is set
            guard let databaseProfile = self.databaseManager.selectedDatabaseProfile else {
                // Skip upload if no database profile is selected
                Self.logger.notice("Skipping upload for: \(url.path(percentEncoded: true))")
                return
            }
            
            guard let jsonURL = exportResult?.jsonManifestPath else {
                Self.logger.error("Failed to upload \(url): missing json URL. Most likely no markers were extracted.")
                throw DatabaseUploadError.missingJsonFile
            }
            
            Self.logger.notice("Upload started. Platform: \(databaseProfile.plaform.rawValue)")

            // Upload
            try await self.databaseUploader.uploadToDatabase(url: jsonURL, databaseProfile: databaseProfile)
            
            Self.logger.notice("Successfully uploaded: \(url.path(percentEncoded: false))")
        }
        
        // MARK: Prepare for extraction
        
        defer {
            self.databaseUploader.resetProgress()
            
            DispatchQueue.main.async {
                self.extractionInProgress = false
                DockProgress.resetProgress()
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
                alertMessage: "Export Folder is not selected. Please select an Export Folder and try again."
            )
            
            return
        }
        
        await prepareExtraction(for: urls)
        
        // MARK: Perform extraction and upload in parallel (in case of multiple files
        
        await withTaskGroup(of: Void.self) { group in
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
        if self.failedTasks.isEmpty {
            // Successful extraction
            Self.logger.notice("All extractions successfull")
            self.exportResult = .success

            // Send notification
            await NotificationManager.sendNotification(taskFinished: true, title: "All complete")
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
                self.databaseUploader.uploadProgress.markasFailed(
                    progressMessage: "Failed to complete upload",
                    alertMessage: alertMessage
                )
            }
        }

        if self.completedOutputFolder == nil {
            self.completedOutputFolder = settings.store.exportFolderURL
        }
    }

    public func clearProgress() async {
        self.exportResult = .none
        self.completedOutputFolder = nil
        self.failedTasks.removeAll()
        self.extractionProgress.reset(taskDescription: "Extract", taskIcon: "gearshape.2")
        self.databaseUploader.uploadProgress.reset()
    }

    public func cancelAll() {
        Self.logger.notice("User initiated cancel.")
        Self.logger.notice("Cancelling task group.")
        
        self.extractionTask?.cancel()
        self.databaseUploader.cancelAll()
    }
}
