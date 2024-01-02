//
//  ExportProfilePicker.swift
//  Marker Data
//
//  Created by Milán Várady on 02/12/2023.
//

import SwiftUI
import MarkersExtractor

struct ExportProfilePicker: View {
    @EnvironmentObject var settings: SettingsContainer
    @EnvironmentObject var databaseManager: DatabaseManager
    
    /// Set in onAppear
    @State var selection: String = ExportProfileFormat.allExtractOnlyNames[0]
    
    var body: some View {
        Picker("Export Profile", selection: $selection) {
            Section("Extract Only (No Upload)") {
                ForEach(ExportProfileFormat.allExtractOnlyNames, id: \.self) { name in
                    Text(name)
                        .tag(name)
                }
            }
            
            Divider()
            
            Section("Database Profiles (Upload)") {
                ForEach(databaseManager.profiles, id: \.self.name) { DBProfile in
                    Text(DBProfile.name)
                        .tag(DBProfile.name)
                }
            }
        }
        .onAppear {
            // Set selection
            if databaseManager.selectedDatabaseProfileName.isEmpty {
                // No upload
                selection = databaseManager.selectedExportFormat.extractOnlyName
            } else {
                // Upload
                selection = databaseManager.selectedDatabaseProfileName
            }
        }
        .onChange(of: selection) { newSelection in
            if ExportProfileFormat.allExtractOnlyNames.contains(newSelection) {
                // No upload
                if let exportProfile = ExportProfileFormat(extractOnlyName: newSelection) {
                    databaseManager.setExportProfile(exportProfile: exportProfile)
                }
            } else {
                // Upload
                databaseManager.setExportProfile(databaseProfileName: selection)
            }
        }
    }
}

#Preview {
    ExportProfilePicker()
}
