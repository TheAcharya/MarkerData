//
//  ConfigurationCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/10/2023.
//

import SwiftUI

struct ConfigurationCommands: Commands {
    @ObservedObject var settings: SettingsContainer
    @Binding var sidebarSelection: MainViews
    
    var body: some Commands {
        CommandMenu("Configurations") {
            Button("Update Active Configuration") {
                Task {
                    do {
                        try await settings.store.saveAsConfiguration()
                        await settings.checkForUnsavedChanges()
                    } catch {
                        print("Failed to update configuration from Menu Bar Command")
                    }
                }
            }
            .disabled(settings.isDefaultActive || !settings.unsavedChanges)
            .keyboardShortcut("s", modifiers: .command)
            
            Button("Discard Changes") {
                do {
                    try settings.discardChanges()
                } catch {
                    print("Failed to discard changes from Menu Bar Command")
                }
            }
            .disabled(!settings.unsavedChanges)
            .keyboardShortcut("z", modifiers: .command)

            Divider()
            
            Button("Open Configurations Panel") {
                deminiaturizeAllWindows()
                sidebarSelection = .configurations
            }
            
            Button("Open Configuration Folder in Finder") {
                NSWorkspace.shared.open(URL.configurationsFolder)
            }
            
            Divider()
            
            Text("Select Configuration")
            
            ForEach(settings.configurations) { store in
                Button {
                    do {
                        try settings.load(store)
                    } catch {
                        print("Failed to load config from menu bar")
                    }
                } label: {
                    if settings.isStoreActive(store) {
                        Label(store.name, systemImage: "checkmark")
                    } else {
                        Text(store.name)
                    }
                }
                .labelStyle(.titleAndIcon)
                .if(settings.keyboardShortcuts.contains(store.name)) { view in
                    let shortcutIndex = settings.keyboardShortcuts.firstIndex(of: store.name) ?? 0
                    let shortcut = KeyEquivalent("\(shortcutIndex + 1)".first ?? "0")

                    return view
                        .keyboardShortcut(shortcut, modifiers: .command)
                }
            }
        }
    }
}
