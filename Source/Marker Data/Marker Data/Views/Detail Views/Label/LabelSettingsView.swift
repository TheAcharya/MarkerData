//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI

struct LabelSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    enum Section: String, CaseIterable, Identifiable {
        case general, token

        var id: String { self.rawValue }

    }

    @State private var section = Section.token

    var body: some View {
         TabView {
             GeneralLabelSettingsView()
                 .tabItem {
                     Text("Appearance")
                 }
        
             OverlaySettingsView()
                 .tabItem {
                     Text("Overlays")
                 }
         }
         .padding(.top)
         .overlayHelpButton(url: Links.labelSettingsURL)
    }

}

#Preview {
    let settings = SettingsContainer()

    return LabelSettingsView()
        .environmentObject(settings)
}
