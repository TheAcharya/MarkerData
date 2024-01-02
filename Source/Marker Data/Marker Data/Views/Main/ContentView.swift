//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
import MarkersExtractor

struct ContentView: View {
    @StateObject private var errorViewModel = ErrorViewModel()

    @ObservedObject var extractionModel: ExtractionModel
    @Binding var sidebarSelection: MainViews
    
    @EnvironmentObject var configurationsModel: ConfigurationsModel

    //Main View Controller
    var body: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                Label("Extract", systemImage: "house")
                    .tag(MainViews.extract)
                
                Section("Export Settings") {
                    Label("General", systemImage: "gearshape")
                        .tag(MainViews.general)
                    
                    Label("Image", systemImage: "photo")
                        .tag(MainViews.image)
                    
                    Label("Label", systemImage: "tag")
                        .tag(MainViews.label)
                    
                    Label("Configurations", systemImage: "briefcase")
                        .if({
                            return configurationsModel.checkForUnsavedChanges()
                        }()) { view in
                            view
                                .badge(
                                Text("Changed")
                                    .font(.system(size: 7, weight: .black))
                            )
                        }
                        .tag(MainViews.configurations)
                    
                    Label("Databases", systemImage: "server.rack")
                        .tag(MainViews.databases)
                    
                    Label("About", systemImage: "info.circle")
                        .tag(MainViews.about)
                }
            }
            .frame(minWidth: WindowSize.sidebarWidth)
        } detail: {
            Group {
                switch sidebarSelection {
                case .extract:
                    ExtractView(extractionModel: extractionModel)
                case .general:
                    GeneralSettingsView()
                case .image:
                    ImageSettingsView()
                case .label:
                    LabelSettingsView()
                case .configurations:
                    ConfigurationSettingsView()
                case .databases:
                    DatabaseSettingsView()
                case .about:
                    AboutView()
                }
            }
            .frame(width: WindowSize.detailWidth)
        }
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var databaseManager = DatabaseManager()

    @StateObject var extractionModel = ExtractionModel(
        settings: settings,
        databaseManager: databaseManager
    )

    return ContentView(
        extractionModel: extractionModel,
        sidebarSelection: .constant(.extract)
    )
    .environmentObject(settings)
}
