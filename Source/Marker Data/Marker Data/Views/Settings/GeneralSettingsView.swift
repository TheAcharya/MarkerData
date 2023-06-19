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
    
    @StateObject private var exportFolderURLModel = FolderURLModel(
        userDefaultsKey: exportFolderPathKey
    )
    
    var body: some View {
        Form {
            VStack {
                Group {
                    Text("Export Destination")
                        .font(.headline)
                    HStack {
                        Text("Set:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        FolderPicker(folderURL: $exportFolderURLModel.folderURL, buttonTitle: "Select Location")
                            .padding(.leading, 5)
                            .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    HStack {
                        Text("")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("\(exportFolderURLModel.folderURL?.path ?? "")")
                            .frame(width: 145, alignment: .leading)
                            .border(.black)
                            .lineLimit(1)
                        Button {
                            if let url = exportFolderURLModel.folderURL {
                               NSWorkspace.shared.open(url)
                           }
                        } label: {
                            Image(systemName: "arrow.up.right.square")
                        }.frame(width: 40, alignment: .leading)
                        .disabled(exportFolderURLModel.folderURL == nil)
                        Spacer(minLength: 150)
                    }
                    HStack {
                        Text("Folder Format:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Picker("", selection: $settingsStore.selectedFolderFormat) {
                            ForEach(UserFolderFormat.allCases, id: \.self) { item in
                                Text(item.displayName).tag(item)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                }
                Group {
                    Divider()
                    Text("Extraction Profile")
                        .font(.headline)
                    HStack {
                        Text("Profile:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        ExportFormatPicker()
                        .labelsHidden()
                        .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    
                    HStack {
                        Text("Exclude Roles:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        ExcludedRolesPicker()
                        .labelsHidden()
                        .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    
                    HStack {
                        Text("Enable Subframes:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Spacer(minLength: 10)
                        Toggle("", isOn: $settingsStore.enabledSubframes)
                            .toggleStyle(CheckboxToggleStyle())
                            .frame(alignment: .leading)
                        Spacer(minLength: 330)
                    }
                    
                    HStack {
                        Text("Clip Boundaries:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Spacer(minLength: 10)
                        Toggle("", isOn: $settingsStore.enabledClipBoundaries)
                            .toggleStyle(CheckboxToggleStyle())
                            .frame(alignment: .leading)
                        Spacer(minLength: 330)
                    }
                    
                    HStack {
                        Text("No Media:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Spacer(minLength: 10)
                        Toggle("", isOn: $settingsStore.enabledNoMedia)
                            .toggleStyle(CheckboxToggleStyle())
                            .frame(alignment: .leading)
                        Spacer(minLength: 330)
                    }
                }
            }
        }
        .overlayHelpButton(url: settingsStore.generalSettingsURL)
        .navigationTitle("General Settings")
        
    }
    
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    
    static var previews: some View {
        GeneralSettingsView()
            .environmentObject(settingsStore)
            .padding()
    }
    
}
