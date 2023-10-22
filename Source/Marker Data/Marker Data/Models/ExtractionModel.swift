import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit
import UniformTypeIdentifiers

class ExtractionModel: ObservableObject, DropDelegate {

    static let supportedContentTypes: [UTType] = [.fcpxml, .fcpxmld]

    @Published var dropPoint: CGPoint? = nil
    @Published var isDropping = false
    @Published var showOutputInFinder = false
    @Published var completedOutputFolder: URL? = nil

    let errorViewModel: ErrorViewModel
    let settings: SettingsContainer
    let progressPublisher: ProgressPublisher

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
        
        return isFileSupported ? DropProposal(operation: .copy) : DropProposal(operation: .forbidden)
    }

    func dropExited(info: DropInfo) {
        self.isDropping = false
        self.dropPoint = nil
    }


    func performDrop(info: DropInfo) -> Bool {

        let providers = info.itemProviders(
            for: Self.supportedContentTypes
        )

        self.progressPublisher.showProgress = true
        self.progressPublisher.updateProgressTo(
            progressMessage: "Received file",
            percentageCompleted: 1
        )
        self.completedOutputFolder = nil

        for provider in providers {
            //UserDefaults.standard.set(nil, forKey:exportFolderPathKey)
            // Check if the provider can load a file URL
            if provider.canLoadObject(ofClass: URL.self) {
                // Load the file URL from the provider
                let _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let fileURL = url {
                        Task {
                            await self.performExtraction(fileURL)
                        }
                    } else if let error = error {
                        // Handle the error
                        DispatchQueue.main.async {
                            self.progressPublisher.markasFailed(
                                errorMessage: "Error: \(error.localizedDescription)"
                            )
                            self.errorViewModel.errorMessage  = error.localizedDescription
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }

        return true

    }

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(
            to: Self.supportedContentTypes
        )
    }

    func performExtraction(_ url: URL) async {

        // Handle the file URL
        print("Dropped file URL: \(url.absoluteString)")
        self.progressPublisher.updateProgressTo(
            progressMessage: "Begin to process file \(url.absoluteString) ",
            percentageCompleted: 2
        )

        do {
            let settings = try self.settings.store.markersExtractorSettings(
                fcpxmlFileUrl: url
            )
            self.progressPublisher.updateProgressTo(
                progressMessage: "Extraction in progress...",
                percentageCompleted: 2
            )
            try await MarkersExtractor(settings).extract()
            self.progressPublisher.updateProgressTo(
                progressMessage: "Extraction successful",
                percentageCompleted: 100
            )
            self.completedOutputFolder = settings.outputDir
            self.showOutputInFinder = true // inform the user
            print("Ok")

        } catch {

            self.progressPublisher.markasFailed(
                errorMessage: "Error: \(error.localizedDescription)"
            )

            self.errorViewModel.errorMessage  = error.localizedDescription
            print("Error: \(error.localizedDescription)")
        }
    }

}
