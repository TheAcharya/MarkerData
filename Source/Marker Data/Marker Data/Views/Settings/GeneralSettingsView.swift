//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct GeneralSettingsView: View {

    @Environment(\.openURL) var openURL

    @EnvironmentObject var settingsStore: SettingsStore
    
    var body: some View {
        VStack(alignment: .formControlAlignment) {
            Group {

                Text("Export Destination")
                    .font(.headline)

                HStack {

                    Text("Destination:")
                        .fixedSize(horizontal: true, vertical: false)

                    FolderPicker(
                        url: settingsStore.$exportFolderURL,
                        title: "Choose…"
                    )

                }

                HStack {

                    Text("Folder Format:")
                        // .border(.green)

                    Picker("", selection: $settingsStore.selectedFolderFormat) {
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

                    ExportFormatPicker()
                        .labelsHidden()
                        .frame(width: 150)
                        .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("Exclude Roles:")

                    ExcludedRolesPicker()
                        .labelsHidden()
                        .frame(width: 150)
                        .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("Enable Subframes:")

                    Toggle("", isOn: $settingsStore.enabledSubframes)
                        .toggleStyle(CheckboxToggleStyle())
                        .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("Clip Boundaries:")

                    Toggle("", isOn: $settingsStore.enabledClipBoundaries)
                        .toggleStyle(CheckboxToggleStyle())
                        .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("No Media:")

                    Toggle("", isOn: $settingsStore.enabledNoMedia)
                        .toggleStyle(CheckboxToggleStyle())
                        .formControlLeadingAlignmentGuide()

                }
            }
        }
        .overlayHelpButton(url: settingsStore.generalSettingsURL)
        .navigationTitle("General Settings")
        
    }
    
}

struct GeneralSettingsView_Previews: PreviewProvider {

    @StateObject static private var settingsStore = SettingsStore()
    
    static var previews: some View {
        GeneralSettingsView()
            .environmentObject(settingsStore)
            .padding()
    }
    
}
