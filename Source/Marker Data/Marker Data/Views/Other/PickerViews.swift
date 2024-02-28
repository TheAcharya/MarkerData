//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI
import MarkersExtractor

struct ImageModePicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("Image Format", selection: $settings.store.imageMode) {
            ForEach(ImageMode.allCases) { imageMode in
                Text(imageMode.displayName).tag(imageMode)
            }
        }
    }
}

struct FontNamePicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("", selection: $settings.store.fontNameType) {
            ForEach(FontNameType.allCases) { fontNameType in
                Text(fontNameType.displayName).tag(fontNameType)
            }
        }
    }
}

struct FontStylePicker: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Picker("", selection: $settings.store.fontStyleType) {
            ForEach(FontStyleType.allCases) { fontStyleType in
                Text(fontStyleType.displayName).tag(fontStyleType)
            }
        }
    }
}
