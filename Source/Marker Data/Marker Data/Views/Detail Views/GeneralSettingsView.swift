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
            Group {

                Text("Export Destination")
                    .font(.headline)

                HStack {
                    Text("Export Folder:")
                        .fixedSize(horizontal: true, vertical: false)

                    ExportDestinationPicker()
                        .frame(maxWidth: 250)
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
                    .frame(width: 150)
                    .formControlLeadingAlignmentGuide()

                }

            }
            Group {

                Divider()

                Text("Extraction Profile")
                    .font(.headline)

                HStack {

                    Text("Profile:")

                    ExportProfilePicker()
                        .labelsHidden()
                        .frame(width: 150)
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
        .overlayHelpButton(url: Links.generalSettingsURL)
        .navigationTitle("General Settings")
        
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
