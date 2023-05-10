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
        HStack {
            VStack(alignment: .leading) {
    
                FolderPicker(folderURL: $exportFolderURLModel.folderURL, buttonTitle: "Select Export Folder")
                if let url = exportFolderURLModel.folderURL {
                    Text("\(url.path)")
                }
                Button("Reveal Destination In Finder") {
                       if let url = exportFolderURLModel.folderURL {
                           NSWorkspace.shared.open(url)
                       }
                   }
                   .disabled(exportFolderURLModel.folderURL == nil)
    
                Divider()
                //Picker To Change Default Export Format
                ExportFormatPicker()
                //Picker To Change Default Exclude Roles
                ExcludedRolesPicker()
                //Toggle To Enable Subframes
                Toggle("Enable Subframes", isOn: settingsStore.$enabledSubframes)
                //Make Toggle A Checkbox
                    .toggleStyle(.checkbox)
            }
            Spacer()
        }
        .padding(.horizontal)
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
