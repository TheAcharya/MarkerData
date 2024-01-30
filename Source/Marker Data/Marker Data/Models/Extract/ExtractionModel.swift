import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit
import UniformTypeIdentifiers
import Logging
import LoggingOSLog

class ExtractionModel: ObservableObject, DropDelegate {
    let databaseManager: DatabaseManager
    
    static let supportedContentTypes: [UTType] = [.fcpxml, .fcpxmld]

    // Drop
    @Published var dropPoint: CGPoint? = nil
    @Published var isDropping = false
    
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
    
    @Published var extractionProgress = ProgressViewModel(taskDescription: "Extract")
    @Published var uploadProgress = ProgressViewModel(taskDescription: "Upload")
    
    public var failedTasks: [ExtractionFailure] = []

    let settings: SettingsContainer
    
//    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ExtractionModel")
    static let logger = Logger(label: Bundle.main.bundleIdentifier!)

    init(settings: SettingsContainer, databaseManager: DatabaseManager) {
        self.settings = settings
        self.databaseManager = databaseManager
        
        // Configure swift-log logging system to use OSLog backend
        LoggingSystem.bootstrap(LoggingOSLog.init)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenDocument(notification:)),
            name: Notification.Name("OpenFile"),
            object: nil)
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkflowExtensionEvent),
            name: Notification.Name("WorkflowExtensionFileReceived"),
            object: nil)
    }
    
    /// Handles the Open Document event, called when file is dragged to dock icon or FCP Share Destination exports
    @objc func handleOpenDocument(notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else {
            Self.logger.error("handleOpenDocument: Couldn't find URL info")
            return
        }
        
        Self.logger.notice("handleOpenDocument: Received url: \(url)")
        
        // Check if URL conforms to supported file types
        if !url.conformsToType(Self.supportedContentTypes) {
            Self.logger.error("handleOpenDocument: File type not supported (\(url.pathExtension))")
            return
        }
        
        // Show UI
        self.showProgressUI = true
            
        // Check if destination folder exists
        if let exportFolder = self.settings.store.exportFolderURL,
           exportFolder.fileExists {
            // Extract
            Task {
                await self.performExtraction([url])
            }
        } else {
            // Default to opening external file recieved popup
            self.externalFileRecieved = true
            self.externalFileURL = url
        }
        
        // Send notification
        NotificationManager.sendNotification(
            taskFinished: false,
            title: "Recieved External File",
            body: "\(url.path(percentEncoded: false))"
        )
    }
    
    /// Handles Workflow Extension notification, and starts the extraction
    @objc func handleWorkflowExtensionEvent() {
        Self.logger.notice("handleWorkflowExtensionEvent: Recieved notification")
        
        let url = URL.workflowExtensionExportFCPXML
        
        // Check if URL conforms to supported file types
        if !url.fileExists {
            Self.logger.error("handleWorkflowExtensionEvent: \(url.path(percentEncoded: false)) doesn't exist")
            return
        }
        
        // Show UI
        self.showProgressUI = true
        
        // Check if destination folder exists
        if let exportFolder = self.settings.store.exportFolderURL,
           exportFolder.fileExists {
            // Extract
            Task {
                await self.performExtraction([url])
            }
        } else {
            // Default to opening external file recieved popup
            self.externalFileRecieved = true
            self.externalFileURL = url
        }
        
        // Send notification
        NotificationManager.sendNotification(
            taskFinished: false,
            title: "Recieved External File",
            body: "\(url.path(percentEncoded: false))"
        )
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

    @MainActor
    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(
            for: [.fileURL]
        )
        
        var filesToProcess: [URL] = []
        
        /// A dispatch group so we can wait for the `provider.loadObject()`
        ///  functions completion handlers to finish before extracting
        let group = DispatchGroup()
        
        // This block will be called when all file URLs have been received
        group.notify(queue: .main) {
            if filesToProcess.isEmpty {
                Self.logger.notice("Drop received no files")
            } else {
                Task {
                    await self.performExtraction(filesToProcess)
                }
            }
        }

        for provider in providers {
            // Check if the provider can load a file URL
            if provider.canLoadObject(ofClass: URL.self) {
                group.enter()
                // Load the file URL from the provider
                let _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let fileURL = url {
                        // Check file type
                        if fileURL.conformsToType(Self.supportedContentTypes) {
                            filesToProcess.append(fileURL)
                        } else {
                            Self.logger.notice("Skipping file \(fileURL.path(percentEncoded: false)). Not supported.")
                        }
                    } else if let error = error {
                        Self.logger.error("File drop error: \(error.localizedDescription)")
                    }
                    
                    group.leave()
                }
            }
        }
        
        group.wait()

        return true
    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: Self.supportedContentTypes)
    }
    
    public func processExternalFile() {
        defer {
            self.externalFileRecieved = false
            self.externalFileURL = nil
        }
        
        guard let url = self.externalFileURL else {
            return
        }
        
        Task {
            await self.performExtraction([url])
        }
    }
    
    public func cancelExternalFile() {
        self.showProgressUI = false
        self.externalFileRecieved = false
        self.externalFileURL = nil
    }
    
    public func clearProgress() {
        self.exportResult = .none
        self.completedOutputFolder = nil
        self.failedTasks.removeAll()
        self.extractionProgress.reset()
        self.uploadProgress.reset()
    }
    
    public func performExtraction(_ urls: [URL]) async {
        func resetVariables() {
            self.clearProgress()
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
                self.showProgressUI = true
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
                progressMessage: "Empty or invalid export destination",
                alertMessage: "Empty or invalid export destination. Please select one."
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
            
            guard let credentials = databaseProfile.notionCredentials else {
                Self.logger.error("Failed to upload to Notion: couldn't retrieve credentials")
                throw DatabaseUploadError.notionNoToken
            }
            
            let logPath = URL.logsFolder
                .appendingPathComponent("csv2notion-neo_log.txt", conformingTo: .plainText).path(percentEncoded: false)
            
            var arguments: [String] = [
                "--workspace", credentials.workspaceName.quoted,
                "--token", credentials.token.quoted,
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
                Self.logger.error("Failed to upload to Notion.\nOutput: \(result.output)")
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
