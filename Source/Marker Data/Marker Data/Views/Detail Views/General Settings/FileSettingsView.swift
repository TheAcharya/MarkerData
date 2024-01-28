//
//  FileSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 25/01/2024.
//

import SwiftUI

struct FileSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        VStack(alignment: .formControlAlignment) {
            exportDestinationSettings
            
            Divider()
            
            extractionProfileSettings
        }
    }
    
    var exportDestinationSettings: some View {
        Group {
            Text("Export Destination")
                .font(.headline)
            
            HStack {
                Text("Export Folder:")
                    .fixedSize(horizontal: true, vertical: false)
                
                ExportDestinationPicker()
                    .frame(maxWidth: 250)
                    .formControlLeadingAlignmentGuide()
            }
            
            HStack {
                
                Text("Folder Format:")
                // .border(.green)
                
                Picker("", selection: $settings.store.selectedFolderFormat) {
                    ForEach(UserFolderFormat.allCases) { item in
                        Text(item.displayName).tag(item)
                    }
                }
                .labelsHidden()
                .frame(width: 250)
                .formControlLeadingAlignmentGuide()
                
            }
        }
    }
    
    var extractionProfileSettings: some View {
        Group {
            Text("Extraction Profile")
                .font(.headline)
            
            HStack {
                Text("Profile:")
                
                ExportProfilePicker()
                    .labelsHidden()
                    .frame(width: 250)
                    .formControlLeadingAlignmentGuide()
            }
            
            HStack {
                Text("Enable Subframes:")
                
                Toggle("", isOn: $settings.store.enabledSubframes)
                    .toggleStyle(CheckboxToggleStyle())
                    .formControlLeadingAlignmentGuide()
            }
            
            HStack {
                Text("No Media:")
                
                Toggle("", isOn: $settings.store.enabledNoMedia)
                    .toggleStyle(CheckboxToggleStyle())
                    .formControlLeadingAlignmentGuide()
                
            }
        }
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var databaseManager = DatabaseManager()
    @StateObject var configurationsModel = ConfigurationsModel()
    
    return FileSettingsView()
        .padding()
        .environmentObject(settings)
        .environmentObject(databaseManager)
        .environmentObject(configurationsModel)
}
