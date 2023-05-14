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
        Picker("", selection: $settingsStore.selectedExportFormat) {
            ForEach(ExportFormat.allCases, id: \.self) { exportFormat in
                Text(exportFormat.displayName).tag(exportFormat)
            }
        }
        .labelsHidden()
    }
}

struct ExcludedRolesPicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("", selection: $settingsStore.selectedExcludeRoles) {
            ForEach(ExcludedRoles.allCases, id: \.self) { excludedRole in
                Text(excludedRole.displayName).tag(excludedRole)
            }
        }.labelsHidden()
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

struct FontNamePicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("", selection: $settingsStore.selectedFontNameType) {
            ForEach(FontNameType.allCases, id: \.self) { fontNameType in
                Text(fontNameType.displayName).tag(fontNameType)
            }
            
        }
    }
}

struct FontStylePicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("", selection: $settingsStore.selectedFontStyleType) {
            ForEach(FontStyleType.allCases, id: \.self) { fontStyleType in
                Text(fontStyleType.displayName).tag(fontStyleType)
            }
            
        }
    }
}
