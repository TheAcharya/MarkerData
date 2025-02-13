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
                await confModel.rename(store: selectedStore, to: configurationNameText)
                configurationNameText.removeAll()
                showRenameConfigurationSheet = false
            } else {
                await confModel.add(saveAs: configurationNameText)
                showAddConfigurationSheet = false
            }
        }

        return VStack(alignment: .leading) {
            Text("\(rename ? "Rename" : "Add") Configuration")
                .font(.system(size: 18, weight: .bold))

            HStack {
                Text("Configuration Name:")

                TextField("Configuration Name", text: $configurationNameText)
                    .onChange(of: configurationNameText) { newName in
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
