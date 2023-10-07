//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct LabelSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore

    enum Section: String, CaseIterable, Identifiable {
        case general, token

        var id: String { self.rawValue }

    }

    @State private var section = Section.token

    var body: some View {

//        VStack {
//            Picker("", selection: $section) {
//                ForEach(Section.allCases) { section in
//                    Text(section.rawValue)
//                        .tag(section)
//                }
//            }
//            .pickerStyle(.segmented)
//            .frame(width: 200)
//            .padding(10)
//            // .border(.green)
//
//            Group {
//                switch section {
//                    case .general:
//                        GeneralLabelSettingsView()
//                    case .token:
//                        TokenLabelSettingsView()
//                }
//            }
//            // .border(.green)
//
//            Spacer()
//
//        }

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
         .overlayHelpButton(url: settingsStore.labelSettingsURL)
    }

}

struct LabelSettingsView_Previews: PreviewProvider {
    @StateObject static private var settingsStore = SettingsStore()

    static var previews: some View {
        LabelSettingsView()
            .environmentObject(settingsStore)
    }
}
