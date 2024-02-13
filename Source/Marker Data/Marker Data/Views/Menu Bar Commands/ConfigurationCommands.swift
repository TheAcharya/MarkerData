//
//  ConfigurationCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/10/2023.
//

import SwiftUI

struct ConfigurationCommands: Commands {
    @ObservedObject var configurationsModel: ConfigurationsModel
    @ObservedObject var settings: SettingsContainer
    @Binding var sidebarSelection: MainViews
    
    var body: some Commands {
        CommandMenu("Configurations") {
            Button("Update Active Configuration") {
                do {
                    try configurationsModel.saveConfiguration(configurationName: configurationsModel.activeConfiguration, replace: true)
                } catch {
                    print("Failed to update configuration from Menu Bar Command")
                }
            }
            .disabled(configurationsModel.activeConfiguration == ConfigurationsModel.defaultConfigurationName)
            .keyboardShortcut("s", modifiers: .command)
            
            Button("Discard Changes") {
                do {
                    try configurationsModel.loadConfiguration(configurationName: configurationsModel.activeConfiguration, settings: settings)
                } catch {
                    print("Failed to discard changes from Menu Bar Command")
                }
            }
            .disabled(!configurationsModel.unsavedChanges)
            .keyboardShortcut("z", modifiers: .command)

            Divider()
            
            Button("Open Configurations Panel") {
                sidebarSelection = .configurations
            }
            
            Button("Open Configuration Folder in Finder") {
                NSWorkspace.shared.open(URL.configurationsFolder)
            }
            
            Divider()
            
            Text("Select Configuration")
            
            ForEach(configurationsModel.configurations) { config in
                Button {
                    do {
                        try configurationsModel.loadConfiguration(configurationName: config.name, settings: settings)
                    } catch {
                        print("Failed to load config from menu bar")
                    }
                } label: {
                    if config.name == configurationsModel.activeConfiguration {
                        Label(config.name, systemImage: "checkmark")
                    } else {
                        Text(config.name)
                    }
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }
}
