//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct ExportFormatPicker: View {
    
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("Profiles", selection: $settingsStore.selectedExportFormat) {
            ForEach(ExportFormat.allCases) { exportFormat in
                Text(exportFormat.displayName).tag(exportFormat)
            }
        }
    }
}

struct ExcludedRolesPicker: View {
    
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("Exclude Roles", selection: $settingsStore.selectedExcludeRoles) {
            ForEach(ExcludedRoles.allCases) { excludedRole in
                Text(excludedRole.displayName).tag(excludedRole)
            }
        }
    }
}

struct ImageModePicker: View {
    
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("Image Format", selection: $settingsStore.selectedImageMode) {
            ForEach(ImageMode.allCases) { imageMode in
                Text(imageMode.displayName).tag(imageMode)
            }
        }
    }
}

struct FontNamePicker: View {
    
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("", selection: $settingsStore.selectedFontNameType) {
            ForEach(FontNameType.allCases) { fontNameType in
                Text(fontNameType.displayName).tag(fontNameType)
            }
        }
    }
}

struct FontStylePicker: View {
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Picker("", selection: $settingsStore.selectedFontStyleType) {
            ForEach(FontStyleType.allCases) { fontStyleType in
                Text(fontStyleType.displayName).tag(fontStyleType)
            }
        }
    }
}