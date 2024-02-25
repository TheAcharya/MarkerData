//
//  FileSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 25/01/2024.
//

import SwiftUI
import MarkersExtractor

struct FileSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        VStack(alignment: .formControlAlignment) {
            Spacer()
            
            exportDestinationSettings
            
            Divider()
            
            extractionProfileSettings
            
            Spacer()
            
            settingsLinksView
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
                
                Picker("", selection: $settings.store.folderFormat) {
                    ForEach(ExportFolderFormat.allCases) { item in
                        Text(item.displayName)
                            .tag(item)
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
    
    var settingsLinksView: some View {
        HStack {
            // Open Files and Folders Access in System Settings
            Button {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders")!)
            } label: {
                Label("Open Files and Folders Access", systemImage: "folder")
            }
            .buttonStyle(.link)
            
            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)
            
            Button {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
            } label: {
                Label("Open Full Disk Access", systemImage: "internaldrive")
            }
            .buttonStyle(.link)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var databaseManager = DatabaseManager(settings: settings)
    
    return FileSettingsView()
        .padding()
        .environmentObject(settings)
        .environmentObject(databaseManager)
}
