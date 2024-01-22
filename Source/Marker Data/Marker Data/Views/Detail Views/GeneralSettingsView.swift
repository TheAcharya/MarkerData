//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct GeneralSettingsView: View {

    @Environment(\.openURL) var openURL

    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        VStack(alignment: .formControlAlignment) {
            exportDestinationSettings
            
            Divider()
            
            extractionProfileSettings
            
            Divider()
            
            progressReportingSettings
        }
        .overlayHelpButton(url: Links.generalSettingsURL)
        .navigationTitle("General Settings")
        
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
    
    var progressReportingSettings: some View {
        Group {
            Text("Progress Reporting")
                .font(.headline)
            
            HStack {
                Text("Notification Frequency:")
                
                Picker("", selection: $settings.store.notificationFrequency) {
                    ForEach(NotificationFrequency.allCases) { frequency in
                        Text(frequency.displayName)
                            .tag(frequency)
                    }
                }
                .labelsHidden()
                .frame(width: 250)
                .formControlLeadingAlignmentGuide()
            }
            
            HStack {
                Text("Show Progress on Dock Icon: ")
                
                Toggle("", isOn: $settings.store.showDockProgress)
                    .formControlLeadingAlignmentGuide()
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    @StateObject static var settings = SettingsContainer()
    @StateObject static var databaseManager = DatabaseManager()
    @StateObject static var configurationsModel = ConfigurationsModel()
    
    static var previews: some View {
        GeneralSettingsView()
            .preferredColorScheme(.dark)
            .environmentObject(settings)
            .environmentObject(databaseManager)
            .environmentObject(configurationsModel)
            .padding()
    }
    
}
