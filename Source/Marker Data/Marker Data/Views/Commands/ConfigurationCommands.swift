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
    @Binding var selectedConfiguration: String
    
    var body: some Commands {
        CommandMenu("Configurations") {
            Button("Update Active Configuration") {
                do {
                    try configurationsModel.saveConfiguration(configurationName: configurationsModel.activeConfiguration, replace: true)
                } catch {
                    print("Failed to update configuration")
                }
            }
            
            Button("Open Configuration Folder in Finder") {
                NSWorkspace.shared.open(
                    URL(fileURLWithPath: URL.configurationsFolder.path().removingPercentEncoding ?? "")
                )
            }
            
            Divider()
            
            Picker("Select Configuration", selection: $selectedConfiguration) {
                ForEach(configurationsModel.configurations) {
                    Text($0.name)
                }
            }
        }
    }
}
