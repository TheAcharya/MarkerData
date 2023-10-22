//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
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
         .overlayHelpButton(url: settings.labelSettingsURL)
    }

}

struct LabelSettingsView_Previews: PreviewProvider {
    @StateObject static private var settings = SettingsContainer()

    static var previews: some View {
        LabelSettingsView()
            .environmentObject(settings)
    }
}
