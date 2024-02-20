//
//  Configurations_AddSheet.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import SwiftUI

extension ConfigurationSettingsView {
    func addOrRenameConfigurationModal(rename: Bool = false) -> some View {
        func doAction() {
            if rename {
                confModel.rename(store: selectedStore, to: configurationNameText)
                showRenameConfigurationSheet = false
            } else {
                confModel.add(saveAs: configurationNameText)
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
                        doAction()
                    }
            }

            HStack {
                Spacer()

                Button("Cancel", role: .cancel) {
                    showAddConfigurationSheet = false
                    showRenameConfigurationSheet = false
                }

                Button("Save") {
                    doAction()
                }
            }
        }
    }
}
