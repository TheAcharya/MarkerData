//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct ExportFormatPicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("Profiles", selection: $settings.store.selectedExportFormat) {
            ForEach(ExportFormat.allCases) { exportFormat in
                Text(exportFormat.displayName).tag(exportFormat)
            }
        }
    }
}

struct ExcludedRolesPicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("Exclude Roles", selection: $settings.store.selectedExcludeRoles) {
            ForEach(ExcludedRoles.allCases) { excludedRole in
                Text(excludedRole.displayName).tag(excludedRole)
            }
        }
    }
}

struct ImageModePicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("Image Format", selection: $settings.store.selectedImageMode) {
            ForEach(ImageMode.allCases) { imageMode in
                Text(imageMode.displayName).tag(imageMode)
            }
        }
    }
}

struct FontNamePicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("", selection: $settings.store.selectedFontNameType) {
            ForEach(FontNameType.allCases) { fontNameType in
                Text(fontNameType.displayName).tag(fontNameType)
            }
        }
    }
}

struct FontStylePicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("", selection: $settings.store.selectedFontStyleType) {
            ForEach(FontStyleType.allCases) { fontStyleType in
                Text(fontStyleType.displayName).tag(fontStyleType)
            }
        }
    }
}
