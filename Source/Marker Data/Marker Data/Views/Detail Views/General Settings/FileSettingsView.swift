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
            
            LabeledFormElement("Export Folder") {
                ExportDestinationPicker()
                    .frame(maxWidth: 250)
            }
            
            LabeledFormElement("Folder Format") {
                Picker("", selection: $settings.store.folderFormat) {
                    ForEach(ExportFolderFormat.allCases) { item in
                        Text(item.displayName)
                            .tag(item)
                    }
                }
                .frame(width: 250)
            }
        }
    }
    
    var extractionProfileSettings: some View {
        Group {
            Text("Extraction Profile")
                .font(.headline)
            
            LabeledFormElement("Profile") {
                ExportProfilePicker()
                    .frame(width: 250)
            }
            
            LabeledFormElement("Enable Subframes") {
                Toggle("", isOn: $settings.store.enabledSubframes)
                    .toggleStyle(CheckboxToggleStyle())
            }

            LabeledFormElement("Include Disabled Clips") {
                Toggle("", isOn: $settings.store.includeDisabledClips)
                    .toggleStyle(CheckboxToggleStyle())
            }

            LabeledFormElement("Use Chapter Marker Pin Image") {
                Toggle("", isOn: $settings.store.useChapterMarkerThumbnails)
                    .toggleStyle(CheckboxToggleStyle())
            }

            LabeledFormElement("Skip Image Generation") {
                Toggle("", isOn: $settings.store.enabledNoMedia)
                    .toggleStyle(CheckboxToggleStyle())
            }
        }
    }
    
    var settingsLinksView: some View {
        HStack {
            // Open Files and Folders Access in System Settings
            Button {
                if let filesAccessURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_FilesAndFolders") {
                    NSWorkspace.shared.open(filesAccessURL)
                }
            } label: {
                Label("Open Files and Folders Access", systemImage: "folder")
            }
            .buttonStyle(.link)
            
            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)
            
            Button {
                if let fullDiskAccessURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles") {
                    NSWorkspace.shared.open(fullDiskAccessURL)
                }
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
    let settings = SettingsContainer()
    let databaseManager = DatabaseManager(settings: settings)
    
    return FileSettingsView()
        .padding()
        .environmentObject(settings)
        .environmentObject(databaseManager)
}
