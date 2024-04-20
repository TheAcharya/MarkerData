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
            ImageExtractionSettingsView()
                .tabItem {
                    Text("Extraction")
                }

            SwatchSettingsView()
                .tabItem {
                    Text("Color Swatch")
                }
        }
        .padding(.top)
        .overlayHelpButton(url: Links.imageSettingsURL)
        .navigationTitle("Image Settings")
    }
}

struct ImageSettingsView_Previews: PreviewProvider {
    static let settings = SettingsContainer()
    
    static var previews: some View {
        ImageSettingsView()
            .environmentObject(settings)
    }
}
