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
        VStack {
            Spacer()
            
            Form {
                ExportDestinationSettings()
                
                ExtractionProfileSettings()
            }
            
            Spacer()

            SettingsLinksView()
        }
    }

    struct ExportDestinationSettings: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("Export Destination")) {
                LabeledContent("Export Folder") {
                    ExportDestinationPicker()
                        .frame(width: WindowSize.pickerWidth)
                }
                
                FixedPicker("Folder Format", selection: $settings.store.folderFormat) {
                    ForEach(ExportFolderFormat.allCases) { item in
                        Text(item.displayName)
                            .tag(item)
                    }
                }
            }
        }
    }

    struct ExtractionProfileSettings: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("Extraction Profile")) {
                LabeledContent("Export Profile") {
                    ExportProfilePicker()
                        .labelsHidden()
                        .applyPickerSizing()
                }
                
                Toggle("Enable Subframes", isOn: $settings.store.enabledSubframes)
                
                Toggle("Include Disabled Clips", isOn: $settings.store.includeDisabledClips)
                
                Toggle("Use Chapter Marker Pin Image", isOn: $settings.store.useChapterMarkerThumbnails)
                
                Toggle("Skip Image Generation", isOn: $settings.store.enabledNoMedia)
            }
        }
    }
    
    struct SettingsLinksView: View {
        var body: some View {
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
}

#Preview {
    let settings = SettingsContainer()
    let databaseManager = DatabaseManager(settings: settings)
    
    return FileSettingsView()
        .padding()
        .environmentObject(settings)
        .environmentObject(databaseManager)
}
