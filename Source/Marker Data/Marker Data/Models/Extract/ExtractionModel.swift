import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit
import UniformTypeIdentifiers
import os

class ExtractionModel: ObservableObject, DropDelegate {
    let databaseManager: DatabaseManager
    
    static let supportedContentTypes: [UTType] = [.fcpxml, .fcpxmld]

    // Drop
    @Published var dropPoint: CGPoint? = nil
    @Published var isDropping = false
    
    @Published var extractionInProgress = false
    @Published var showProgress = false
    @Published var exportResult: ExportExitStatus = .none
    @Published var completedOutputFolder: URL? = nil
    
    @Published var extractionProgress = ProgressViewModel(taskDescription: "Extract")
    @Published var uploadProgress = ProgressViewModel(taskDescription: "Upload")
    
    public var failedTasks: [ExtractionFailure] = []

    let errorViewModel: ErrorViewModel
    let settings: SettingsContainer
    
    static let logger = Logger()

    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.errorViewModel = ErrorViewModel()
        self.settings = settings
        self.databaseManager = databaseManager
    }

    func dropEntered(info: DropInfo) {
        self.isDropping = true
        self.dropPoint = info.location
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.dropPoint = info.location
        
        let isFileSupported = info.hasItemsConforming(to: Self.supportedContentTypes)
        
        return if isFileSupported && !self.extractionInProgress {
            DropProposal(operation: .copy) }
        else {
            DropProposal(operation: .forbidden)
        }
    }

    func dropExited(info: DropInfo) {
        self.isDropping = false
        self.dropPoint = nil
    }


    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(
            for: [.fileURL]
        )
        
        var filesToProcess: [URL] = []

        for provider in providers {
            // Check if the provider can load a file URL
            if provider.canLoadObject(ofClass: URL.self) {
                // Load the file URL from the provider
                let _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let fileURL = url {
                        // Check file type
                        if fileURL.conformsToType(Self.supportedContentTypes) {
                            filesToProcess.append(fileURL)
                        } else {
                            Self.logger.notice("Skipping file \(url?.path(percentEncoded: false) ?? ""). Not supported.")
                        }
                    } else if let error = error {
                        // Handle the error
                        DispatchQueue.main.async {
                            self.extractionProgress.markasFailed(
                                progressMessage: "Failed to load files",
                                alertMessage: "Error: \(error.localizedDescription)"
                            )
                            
                            self.errorViewModel.errorMessage  = error.localizedDescription
                            
                            Self.logger.error("File drop error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        Task {
            await self.performExtraction(filesToProcess)
        }

        return true
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: Self.supportedContentTypes)
    }
    
    func performExtraction(_ urls: [URL]) async {
        func resetVariables() {
            self.exportResult = .none
            self.completedOutputFolder = nil
            self.failedTasks.removeAll()
            self.extractionProgress.reset()
            self.uploadProgress.reset()
        }
        
        func validateExportDestination() throws {
            var isDir : ObjCBool = false
            
            let exportPath: String = settings.store.exportFolderURL?.path(percentEncoded: false) ?? ""
            
            if !FileManager.default.fileExists(atPath: exportPath, isDirectory: &isDir) {
                Self.logger.error("Extract error: Empty or invalid export destination")
                
                throw ExtractError.invalidExportDestination
            }
        }
        
        func prepareExtraction(for urls: [URL]) async {
            self.extractionInProgress = true
            Self.logger.notice("Processing files: \(urls.map { $0.path(percentEncoded: false) })")
            
            self.extractionProgress.setProcesses(urls: urls)
            
            // Show extraction progress
            await MainActor.run {
                self.showProgress = true
            }
        }
        
        @Sendable 
        func extractAndUpdateProgress(for url: URL) async throws -> ExportResult? {
            // Get extraction settings
            guard let settings = try? self.settings.store.markersExtractorSettings(fcpxmlFileUrl: url) else {
                throw ExtractError.settingsReadError
            }
            
            let extractor = MarkersExtractor(settings)
            
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
                Self.logger.notice("Skipping upload for: \(url)")
                return
            }
            
            guard let jsonURL = exportResult?.jsonManifestPath else {
                Self.logger.error("Failed to upload \(url): missing json URL")
                throw DatabaseUploadError.missingJsonFile
            }
            
            Self.logger.notice("Upload started")
            
            // Add process to upload progress
            await self.uploadProgress.addProcess(url: jsonURL)
            
            // Upload
            try await self.uploadToDatabase(url: jsonURL, databaseProfile: databaseProfile)
            
            Self.logger.notice("Successfully uploaded: \(url.path(percentEncoded: false))")
        }
        
        // MARK: Prepare for extraction
        
        defer {
            self.extractionInProgress = false
        }
        
        Self.logger.notice("Extraction started")
        
        resetVariables()
        
        // Validate export destination
        do {
            try validateExportDestination()
        } catch {
            self.extractionProgress.markasFailed(
                progressMessage: "Failed: Empty or invalid export destination",
                alertMessage: "Failed: Empty or invalid export destination. Please select one."
            )
        }
        
        await prepareExtraction(for: urls)
        
        // MARK: Perform extraction and upload in parallel (in case of multiple files
        
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    var exportResult: ExportResult? = nil
                    
                    // Extract
                    do {
                        exportResult = try await extractAndUpdateProgress(for: url)
                    } catch {
                        await MainActor.run {
                            self.failedTasks.append(
                                ExtractionFailure(url: url, exitStatus: .failedToExtract, errorMessage: error.localizedDescription)
                            )
                        }
                    }
                    
                    // Upload to database (if a database profile is selected)
                    do {
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

            self.completedOutputFolder = settings.store.exportFolderURL
        }
    }
    
    private func uploadToDatabase(url: URL, databaseProfile: DatabaseProfileModel) async throws {
        func uploadToNotion() async throws {
            guard let csv2notionURL = Bundle.main.url(forResource: "csv2notion_neo", withExtension: nil) else {
                Self.logger.error("Failed to upload to Notion: csv2notion executable not found")
                throw DatabaseUploadError.csv2notionExecutableNotFound
            }
            
            let executablePath = csv2notionURL.path(percentEncoded: false).quoted
            
            guard let token = databaseProfile.notionCredentials?.token else {
                Self.logger.error("Failed to upload to Notion: token not found.")
                throw DatabaseUploadError.notionNoToken
            }
            
            let logPath = URL.databaseFolder.appendingPathComponent("csv2notion_log.txt", conformingTo: .plainText).path(percentEncoded: false)
            
            var arguments: [String] = [
                "--token", token.quoted,
                "--image-column", "Image Filename".quoted,
                "--image-column-keep",
                "--mandatory-column", "Marker ID".quoted,
                "--payload-key-column", "Marker ID".quoted,
                "--icon-column", "Icon Image".quoted,
                "--max-threads", "5",
                "--log", logPath.quoted,
                (url.path(percentEncoded: false)).quoted
            ]
            
            // Add database url if defined
            if let databaseUrl = databaseProfile.notionCredentials?.databaseURL {
                arguments.insert(contentsOf: ["--url", databaseUrl.quoted, "--merge"], at: 2)
            }
            
            // Add rename key column if defined
            if let renameKeyColumn = databaseProfile.notionCredentials?.renameKeyColumn {
                if !renameKeyColumn.isEmpty {
                    arguments.append(contentsOf: ["--rename-notion-key-column", "Marker ID".quoted, renameKeyColumn.quoted])
                }
            }
            
            let command = "\(executablePath) \(arguments.joined(separator: " "))"
            
            let shellOutputStream = ShellOutputStream()
            
            let percentRegex = /([0-9]+)%/
            
            // Update progress
            let cancellable = shellOutputStream.outputPublisher.sink(receiveValue: { output in
                if let match = output.firstMatch(of: percentRegex),
                   let percent = match.1.int {
                    Task {
                        await self.uploadProgress.updateProgress(of: url, to: Int64(percent))
                    }
                }
            })
            
            let result = await shellOutputStream.run(command)
            
            cancellable.cancel()
            
            if result.didFail {
                // Failure
                Self.logger.error("Failed to upload to Notion. Command: \(command). Output: \(result.output)")
                throw DatabaseUploadError.notionUploadError
            } else {
                // Success
                await self.uploadProgress.markProcessAsFinished(url: url)
            }
        }
        
        switch databaseProfile.plaform {
        case .notion:
            try await uploadToNotion()
        case .airtable:
            break
        }
    }
}
