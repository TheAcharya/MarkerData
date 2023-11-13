import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit
import UniformTypeIdentifiers
import os

class ExtractionModel: ObservableObject, DropDelegate {
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
        progressPublisher: ProgressPublisher
    ) {
        self.errorViewModel = ErrorViewModel()
        self.settings = settings
        self.progressPublisher = progressPublisher
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
                        
                        try await extractor.extract()
                        
                        await MainActor.run {
                            filesCompleted += 1
                            
                            if filesCompleted == urls.count {
                                // All extractions complete
                                self.progressPublisher.updateProgressTo(
                                    progressMessage: "Extraction completed",
                                    percentageCompleted: 100,
                                    icon: "checkmark"
                                )
                                
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
                        
                        Self.logger.notice("Extraction complete.")
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
}
