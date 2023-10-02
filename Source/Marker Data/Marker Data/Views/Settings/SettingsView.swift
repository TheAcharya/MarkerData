////
////  Marker Data • https://github.com/TheAcharya/MarkerData
////  Licensed under MIT License
////
////  Maintained by Peter Schorn
////
//
//import SwiftUI
//
//// TODO: Delete this. Moved into the siderbar in the main interface
//
//struct SettingsView: View {
//    
//    @Environment(\.managedObjectContext) var viewContext
//
//    @EnvironmentObject var settingsStore: SettingsStore
//    
//    //Main Settings View Controller
//    var body: some View {
//        Group {
//            if #available(macOS 13.0, *) {
//                NavigationSplitView(
//                    sidebar: { sidebarView },
//                    detail: { detailView }
//                )
//                // only available in macOS 13+
//                .toolbar(.hidden)
//            } else {
//                // Fallback On Earlier Versions
//                NavigationView {
//                    sidebarView
//                    
//                    //Show App Icon And App Title When No Setting Section Is Selected
//                    detailView
//                }
//            }
//        }
//        // Set Settings Window Static Width And Height
//        .frame(width: 700, height: 500)
//    }
//
//    var sidebarView: some View {
//        List(
//            SettingsSection.allCases,
//            selection: $settingsStore.settingsSection
//        ) { section in
//
//            Group {
//                switch section {
//                    case .general:
//                        Label("General", systemImage: "gearshape")
//                            .tag(SettingsSection.general)
//
//                    case .image:
//                        Label("Image", systemImage: "photo")
//                            .tag(SettingsSection.image)
//
//                    case .label:
//                        Label("Label", systemImage: "tag")
//                            .tag(SettingsSection.label)
//
//                    case .configurations:
//                        Label("Configurations", systemImage: "briefcase")
//                            .tag(SettingsSection.configurations)
//
//                    case .databases:
//                        Label("Databases", systemImage: "server.rack")
//                            .tag(SettingsSection.databases)
//
//                    case .about:
//                        Label("About", systemImage: "info.circle")
//                            .tag(SettingsSection.about)
//
//                }
//            }
//            .padding(.vertical, 5)
//
//        }
//        .listStyle(.sidebar)
//        .modify { view in
//            if #available(macOS 13.0, *) {
//                view
//                    .navigationSplitViewColumnWidth(190)
//            }
//            else {
//                view
//            }
//        }
//
//    }
//
//    @ViewBuilder var detailView: some View {
//        switch settingsStore.settingsSection {
//            case .general:
//                GeneralSettingsView()
//            case .image:
//                ImageSettingsView()
//            case .label:
//                LabelSettingsView()
//            case .configurations:
//                ConfigurationSettingsView()
//            case .databases:
//                DatabaseSettingsView()
//            case .about, nil:
//                AboutView()
//        }
//    }
//
//    
//}
//
//struct SettingsView_Previews: PreviewProvider {
//
//    @StateObject static private var settingsStore = SettingsStore()
//
//    static var previews: some View {
//        SettingsView()
//            .environmentObject(settingsStore)
//    }
//
//}
