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

    @Published var dropPoint: CGPoint? = nil
    @Published var isDropping = false
    @Published var showOutputInFinder = false
    @Published var completedOutputFolder: URL? = nil
    @Published var extractionInProgresss = false

    let errorViewModel: ErrorViewModel
    let settings: SettingsContainer
    let progressPublisher: ProgressPublisher
    
    var observation: NSKeyValueObservation?
    
    static let logger = Logger()

    init(
        settings: SettingsContainer,
        progressPublisher: ProgressPublisher,
        databaseManager: DatabaseManager
    ) {
        self.errorViewModel = ErrorViewModel()
        self.settings = settings
        self.progressPublisher = progressPublisher
        self.databaseManager = databaseManager
    }

    func dropEntered(info: DropInfo) {
        self.isDropping = true
        self.dropPoint = info.location
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        self.dropPoint = info.location
        
        let isFileSupported = info.hasItemsConforming(to: Self.supportedContentTypes)
        
        return if isFileSupported && !self.extractionInProgresss {
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

        self.progressPublisher.showProgress = true
        self.progressPublisher.updateProgressTo(
            progressMessage: "Received file",
            percentageCompleted: 1
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
                            self.progressPublisher.markasFailed(
                                errorMessage: "Error: \(error.localizedDescription)"
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
        defer {
            self.extractionInProgresss = false
        }
        
        Self.logger.notice("Extraction started")
        
        // Reset
        self.completedOutputFolder = nil
        
        // Check for invalid export destination
        var isDir : ObjCBool = false
        
        let exportPath: String = settings.store.exportFolderURL?.path(percentEncoded: false) ?? ""
        
        if !FileManager.default.fileExists(atPath: exportPath, isDirectory: &isDir) {
            self.progressPublisher.markasFailed(errorMessage: "Failed: Empty or invalid export destination")
            self.errorViewModel.errorMessage = "Empty or invalid export destination."
            
            Self.logger.error("Extract error: Empty or invalid export destination")
            
            return
        }
        
        withAnimation {
            self.extractionInProgresss = true
        }
        
        // Handle the file URL
        Self.logger.notice("Processing files: \(urls.map { $0.path(percentEncoded: false) })")
        
        self.progressPublisher.showProgress = true
        self.progressPublisher.updateProgressTo(
            progressMessage: "Begin to process \(urls.count) file\(urls.count > 1 ? "s": "")",
            percentageCompleted: 2
        )
        
        var filesCompleted = 0
        var failedTasks: [ExtractionFailure] = []
        
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    do {
                        let settings = try self.settings.store.markersExtractorSettings(
                            fcpxmlFileUrl: url
                        )
                        
                        let extractor = MarkersExtractor(settings)
                        
                        // Observe progress changes (only in case of a single file)
                        if urls.count == 1 {
                            await MainActor.run {
                                self.observation = extractor.observe(
                                    \.progress.fractionCompleted,
                                     options: [.old, .new]
                                ) { object, change in
                                    Task {
                                        await MainActor.run {
                                            self.progressPublisher.updateProgressTo(
                                                progressMessage: "Extracting...",
                                                percentageCompleted: Int(change.newValue! * 100),
                                                icon: "gearshape"
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        
                        let exportResult = try await extractor.extract()
                        
                        Self.logger.notice("Successfully extracted: \(url.path(percentEncoded: false))")
                        
                        // If processing one file update progress to uploading
                        if urls.count == 1 {
                            await MainActor.run {
                                self.progressPublisher.updateProgressTo(progressMessage: "Preparing to Upload...", percentageCompleted: 0, icon: "square.and.arrow.up")
                            }
                        }
                        
                        // Upload csv to notion or airtable
                        if let csvURL = exportResult.csvManifestPath {
                            do {
                                Self.logger.notice("Upload started")
                                
                                try await self.uploadToDatabase(csvPath: csvURL, databaseManager: self.databaseManager)
                                
                                Self.logger.notice("Successfully uploaded: \(url.path(percentEncoded: false))")
                            } catch {
                                await MainActor.run {
                                    Self.logger.error("Upload failed")
                                    failedTasks.append(ExtractionFailure(url: url, exitStatus: .failedToUpload))
                                }
                            }
                        } else {
                            await MainActor.run {
                                Self.logger.error("Upload failed: Couldn't retrieve json path")
                                failedTasks.append(ExtractionFailure(url: url, exitStatus: .failedToUpload))
                            }
                        }
                        
                        await MainActor.run {
                            filesCompleted += 1
                            
                            // All extractions complete
                            if filesCompleted == urls.count {
                                if failedTasks.isEmpty {
                                    self.progressPublisher.updateProgressTo(
                                        progressMessage: "Extraction completed",
                                        percentageCompleted: 100,
                                        icon: "checkmark"
                                    )
                                    
                                    Self.logger.notice("All extractions successfull")
                                } else {
                                    var message = "Failed to complete the following files:"
                                    
                                    for failure in failedTasks {
                                        message += "\n\(failure.url.lastPathComponent), reason: \(failure.exitStatus.rawValue)"
                                    }
                                    
                                    Self.logger.error("\(message)")
                                    
                                    self.progressPublisher.markasFailed(errorMessage: "Failed to complete", alertMessage: message)
                                }
                                
                                self.completedOutputFolder = settings.outputDir
                                self.showOutputInFinder = true // Inform the user
                            } else if urls.count > 1 {
                                // Update progress in case of multiple files
                                self.progressPublisher.updateProgressTo(
                                    progressMessage: "Extracting files \(filesCompleted)/\(urls.count)...",
                                    percentageCompleted: (100/urls.count) * filesCompleted,
                                    icon: "gearshape"
                                )
                            }
                        }
                    } catch {
                        self.progressPublisher.markasFailed(
                            errorMessage: "Error: \(error.localizedDescription)"
                        )
                        
                        self.errorViewModel.errorMessage = error.localizedDescription
                        
                        Self.logger.error("Extraction error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func uploadToDatabase(csvPath: URL, databaseManager: DatabaseManager) async throws {
        guard let profile = databaseManager.selectedDatabaseProfile else {
            Self.logger.notice("Skipping upload: No database profile selected")
            return
        }
        
        switch profile.plaform {
        case .notion:
            guard let csv2notionURL = Bundle.main.url(forResource: "csv2notion_neo", withExtension: nil) else {
                Self.logger.error("Failed to upload to Notion: csv2notion executable not found")
                throw DatabaseUploadError.csv2notionExecutableNotFound
            }
            
            let executablePath = csv2notionURL.path(percentEncoded: false).quoted
            
            guard let token = profile.notionCredentials?.token else {
                Self.logger.error("Failed to upload to Notion: token not found.")
                throw DatabaseUploadError.notionNoToken
            }
            
            let logPath = URL.databaseFolder.appendingPathComponent("csv2notion_log.txt", conformingTo: .plainText).path(percentEncoded: false)
            
            var arguments: [String] = [
                "--token", token.quoted,
                "--image-column", "Image Filename".quoted,
                "--image-column-keep",
                "--mandatory-column", "Marker ID".quoted,
                "--icon-column", "Icon Image".quoted,
                "--max-threads", "5",
                "--merge",
                "--log", logPath.quoted,
                (csvPath.path(percentEncoded: false)).quoted
            ]
            
            // Add database url if defined
            if let databaseUrl = profile.notionCredentials?.databaseURL {
                arguments.insert(contentsOf: ["--url", databaseUrl.quoted], at: 2)
            }
            
            let command = "\(executablePath) \(arguments.joined(separator: " "))"
            
            let shellOutputStream = ShellOutputStream()
            
            let percentRegex = /([0-9]+)%/
            
            // Update progress
            let cancellable = shellOutputStream.outputPublisher.sink(receiveValue: { output in
                if let match = output.firstMatch(of: percentRegex),
                   let percent = match.1.int {
                    self.progressPublisher.updateProgressTo(
                        progressMessage: "Uploading...",
                        percentageCompleted: percent,
                        icon: "square.and.arrow.up"
                    )
                }
            })
            
            let result = await shellOutputStream.run(command)
            
            cancellable.cancel()
            
            if result.didFail {
                Self.logger.error("Failed to upload to Notion. Command: \(command). Output: \(result.output)")
                throw DatabaseUploadError.notionUploadError
            }
        case .airtable:
            break
        }
    }
}
