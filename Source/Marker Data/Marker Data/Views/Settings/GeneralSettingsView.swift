//
//  GeneralSettingsView.swift
//  Marker Data
//
//  Created by Theo S on 07/05/2023.
//

import SwiftUI

struct GeneralSettingsView: View {
    @StateObject private var exportFolderURLModel = FolderURLModel(userDefaultsKey: exportFolderPathKey)
    @EnvironmentObject var settingsStore: SettingsStore
    
    var body: some View {
        Form {
            VStack {
                Group {
                    Text("Export  Destination")
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
                        Text("Enable SubFrame:")
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

    //Set Navigation Bar Title To General
      .navigationTitle("General")
    }
}


struct GeneralSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        GeneralSettingsView().environmentObject(settingsStore)
    }
}
