//
//  ConfigurationSettingsView.swift
//  Marker Data
//
//  Created by Theo S on 10/05/2023.
//

import SwiftUI

struct ConfigurationSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    var body: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Configuration Management Table
                    //USE SWIFTUI TABLE COMPONENT
                    //Button To Export Marker Data Settings
                    Button(action: {}) {
                        Text("Export Marker Data Configurations")
                    }
                    //Button To Import Marker Data Settings
                    Button(action: {}) {
                        Text("Import Marker Data Configurations")
                    }
                    //Button To Load Default Marker Data Settings
                    Button(action: {}) {
                        Text("Load Defaults")
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        //Set Navigation Bar Title To Configuration
        .navigationTitle("Configuration")
    }
}

struct ConfigurationSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        ConfigurationSettingsView().environmentObject(settingsStore)
    }
}
