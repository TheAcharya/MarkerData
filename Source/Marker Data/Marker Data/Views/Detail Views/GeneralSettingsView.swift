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
                    Text("Destination:")
                        .fixedSize(horizontal: true, vertical: false)

                    FolderPicker(
                        url: $settings.store.exportFolderURL,
                        title: "Choose…"
                    )
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

                    ExportFormatPicker()
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

                    Text("Clip Boundaries:")

                    Toggle("", isOn: $settings.store.enabledClipBoundaries)
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

    @StateObject static private var settings = SettingsContainer()
    
    static var previews: some View {
        GeneralSettingsView()
            .environmentObject(settings)
            .padding()
    }
    
}
