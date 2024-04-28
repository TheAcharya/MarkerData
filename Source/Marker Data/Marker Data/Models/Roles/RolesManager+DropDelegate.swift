//
//  RolesManager+DropDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 28/04/2024.
//

import SwiftUI
import MarkersExtractor

extension RolesManager: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        self.loadingInProgress = true

        let providers = info.itemProviders(
            for: [.fcpxml, .fileURL]
        )

        for provider in providers {
            // Load FCPXML
            if provider.hasRepresentationConforming(toTypeIdentifier: "com.apple.finalcutpro.xml") {
                _ = provider.loadDataRepresentation(for: .fcpxml) { data, error in
                    Task {
                        defer {
                            Task {
                                await MainActor.run {
                                    self.loadingInProgress = false
                                }
                            }
                        }

                        guard let dataUnwrapped = data else {
                            return
                        }

                        if let extractedRoles = await self.getRoles(fcpxml: FCPXMLFile(fileContents: dataUnwrapped)) {
                            await self.setRoles(extractedRoles)
                        }
                    }
                }
            }

            // Load FCPXMLD
            if provider.canLoadObject(ofClass: URL.self) {
                // Load the file URL from the provider
                let _ = provider.loadObject(ofClass: URL.self) { url, error in
                    Task {
                        defer {
                            self.loadingInProgress = false
                        }

                        guard let urlUnwrapped = url else {
                            return
                        }

                        if !urlUnwrapped.conformsToType([.fcpxmld]) {
                            Self.logger.warning("File doesn't conform to FCPXMLD")
                            return
                        }

                        if let extractedRoles = await self.getRoles(fcpxml: try FCPXMLFile(at: urlUnwrapped)) {
                            self.setRoles(extractedRoles)
                        }
                    }
                }
            }
        }

        return true
    }

    private func getRoles(fcpxml: FCPXMLFile) async -> [RoleModel]? {
        do {
            let rolesExtractor = RolesExtractor(fcpxml: fcpxml)

            let roles = try await rolesExtractor.extract()

            let roleModels = roles.map { RoleModel(role: $0, enabled: true) }

            return roleModels
        } catch {
            Self.logger.error("Failed to extract roles")
            return nil
        }
    }
}
