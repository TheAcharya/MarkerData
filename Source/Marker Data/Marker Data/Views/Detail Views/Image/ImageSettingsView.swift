//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI

struct ImageSettingsView: View {
    var body: some View {
        TabView {
            Tab("Extraction", systemImage: "photo") {
                ImageExtractionSettingsView()
            }

            Tab("Swatch", systemImage: "paintpalette") {
                SwatchSettingsView()
            }
        }
        .padding(.top)
        .overlayHelpButton(url: Links.imageSettingsURL)
        .navigationTitle("Image Settings")
    }
}

#Preview {
    let settings = SettingsContainer()

    return ImageSettingsView()
        .environmentObject(settings)
}
