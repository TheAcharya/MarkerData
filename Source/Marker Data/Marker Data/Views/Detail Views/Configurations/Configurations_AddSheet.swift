//
//  Configurations_AddSheet.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import SwiftUI
import ButtonKit

extension ConfigurationSettingsView {
    func addOrRenameConfigurationModal(rename: Bool = false) -> some View {
        func doAction() async {
            if rename {
                guard await confModel.rename(store: selectedStore, to: configurationNameText) else {
                    // Dismiss sheet so the parent alert presents as a top-level dialog with icon.
                    showRenameConfigurationSheet = false
                    return
                }
                configurationNameText.removeAll()
                showRenameConfigurationSheet = false
            } else {
                guard await confModel.add(saveAs: configurationNameText) else {
                    showAddConfigurationSheet = false
                    return
                }
                configurationNameText.removeAll()
                showAddConfigurationSheet = false
            }
        }

        return VStack(alignment: .leading) {
            Text("\(rename ? "Rename" : "Add") Configuration")
                .font(.system(size: 18, weight: .bold))

            HStack {
                Text("Configuration Name:")

                TextField("Configuration Name", text: $configurationNameText)
                    .onChange(of: configurationNameText) { oldValue, newName in
                        // Limit characters to 50
                        configurationNameText = String(newName.prefix(50))
                    }
                    .onSubmit {
                        Task {
                            await doAction()
                        }
                    }
            }

            HStack {
                Spacer()

                Button("Cancel", role: .cancel) {
                    configurationNameText.removeAll()
                    showAddConfigurationSheet = false
                    showRenameConfigurationSheet = false
                }

                AsyncButton("Save") {
                    await doAction()
                }
            }
        }
    }
}
