//
//  Configurations_ContextMenu.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import SwiftUI

extension ConfigurationSettingsView {
    func contextMenuButtons(for store: SettingsStore) -> some View {
        VStack {
            // Load configuration
            Button {
                confModel.makeActive(store)
            } label: {
                Label("Make Active", systemImage: "largecircle.fill.circle")
            }
            .disabled(selectedStoreName == settings.store.name)

            Button {
                confModel.duplicateConfiguration(store: store)
            } label: {
                Label("Duplicate", systemImage: "square.filled.on.square")
            }

            // If active configuration
            if store.name == settings.store.name {
                // Discard changes button
                Button {
                    confModel.discardChanges()
                } label: {
                    Label("Discard Changes", systemImage: "circle.slash")
                }
                .disabled(!settings.unsavedChanges)
            }

            // If not default configuration
            if !store.isDefault() {
                if settings.isStoreActive(store) {
                    // Update configuration
                    Button {
                        confModel.updateCurrent()
                    } label: {
                        Label("Update", systemImage: "gearshape.arrow.triangle.2.circlepath")
                    }
                    .disabled(!settings.unsavedChanges)
                }

                // Rename configuration
                Button {
                    showRenameConfigurationSheet = true
                } label: {
                    Label("Rename", systemImage: "square.and.pencil")
                }

                Divider()

                // Remove configuration
                Button(role: .destructive) {
                    confModel.remove(name: store.name)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
        .labelStyle(.titleAndIcon)
    }
}
