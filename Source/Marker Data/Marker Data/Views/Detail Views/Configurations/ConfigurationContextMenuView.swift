//
//  ConfigurationContextMenuView.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import SwiftUI

struct ConfigurationContextMenuView: View {
    @EnvironmentObject var settings: SettingsContainer

    @ObservedObject var confModel: ConfigurationsViewModel
    @Binding var store: SettingsStore
    @Binding var selectedStoreName: String
    @Binding var showRenameConfigurationSheet: Bool

    var body: some View {
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

            Divider()

            Menu {
                ForEach(Array(settings.keyboardShortcuts.enumerated()), id: \.offset) { index, confName in
                    Button {
                        if settings.keyboardShortcuts[index] == store.name {
                            // Unassign shortcut
                            settings.keyboardShortcuts[index] = ""
                        } else {
                            // Remove previous bindings
                            settings.keyboardShortcuts = settings.keyboardShortcuts.map { $0 == store.name ? "" : $0 }
                            // Assign shortcut
                            settings.keyboardShortcuts[index] = store.name
                        }

                        // Call objectWillChange manually as keyboardShortcuts is not a published property
                        settings.objectWillChange.send()
                    } label: {
                        // We have to add the tick symbol this a hacky way because
                        // the Menu view ignores any other types layout modifiers
                        HStack {
                            // Tick or space
                            Text(confName == store.name ? "✓ " : String(repeating: " ", count: 4)) +
                            // Shortcut
                            Text("⌘ \(index + 1)")
                        }
                    }
                }
            } label: {
                Label("Assign Shortcut", systemImage: "command")
            }
        }
        .labelStyle(.titleAndIcon)
    }
}
