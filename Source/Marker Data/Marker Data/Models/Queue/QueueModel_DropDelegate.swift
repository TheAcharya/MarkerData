//
//  QueueModel_DropDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 17/02/2024.
//

import SwiftUI

extension QueueModel: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(
            for: [.fileURL]
        )

        if !providers.contains(where: { $0.canLoadObject(ofClass: URL.self) }) {
            return false
        }

        // Clear current queue instances
        self.queueInstances.removeAll()

        for provider in providers {
            // Check if the provider can load a file URL
            if provider.canLoadObject(ofClass: URL.self) {
                // Load the file URL from the provider
                let _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        // Check file type
                        if url.hasDirectoryPath {
                            Task {
                                try await self.scanFolder(at: url, append: true)
                            }
                        } else {
                            Self.logger.notice("Skipping file \(url.path(percentEncoded: false)). Not supported.")
                        }
                    } else if let error = error {
                        Self.logger.error("File drop error: \(error.localizedDescription)")
                    }
                }
            }
        }

        return true
    }
}
