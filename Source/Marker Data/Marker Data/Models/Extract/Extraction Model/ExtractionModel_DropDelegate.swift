//
//  ExtractionModel_DropDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 04/02/2024.
//

import Foundation
import SwiftUI

extension ExtractionModel: DropDelegate {
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let isFileSupported = info.hasItemsConforming(to: Self.supportedContentTypes)
        
        return if isFileSupported && !self.extractionInProgress {
            DropProposal(operation: .copy) }
        else {
            DropProposal(operation: .forbidden)
        }
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
}