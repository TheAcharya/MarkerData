//
//  ExportFormatPicker.swift
//  Marker Data
//
//  Created by Theo S on 26/04/2023.
//

import SwiftUI

struct ExportFormatPicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("Export Format", selection: $settingsStore.selectedExportFormat) {
            ForEach(ExportFormat.allCases, id: \.self) { exportFormat in
                Text(exportFormat.displayName).tag(exportFormat)
            }
        }
    }
}

struct ExcludedRolesPicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("Exclude Roles", selection: $settingsStore.selectedExcludeRoles) {
            ForEach(ExcludedRoles.allCases, id: \.self) { excludedRole in
                Text(excludedRole.displayName).tag(excludedRole)
            }
        }
    }
}

struct ImageModePicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("Image Mode", selection: $settingsStore.selectedImageMode) {
            ForEach(ImageMode.allCases, id: \.self) { imageMode in
                Text(imageMode.displayName).tag(imageMode)
            }
        }
    }
}
