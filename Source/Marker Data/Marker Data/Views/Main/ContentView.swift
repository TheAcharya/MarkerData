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
    @ObservedObject var progressPublisher: ProgressPublisher
   
    @EnvironmentObject var settingsStore: SettingsStore
    
    /// Currently selected item in the sidebar
    @State var sidebarSelection: MainViews = .extract
    
    enum MainViews: String, CaseIterable, Identifiable {
        case extract
        case general
        case image
        case label
        case configurations
        case databases
        case about

        var id: String {
            self.rawValue
        }

    }

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
                        .tag(MainViews.configurations)
                    
                    Label("Databases", systemImage: "server.rack")
                        .tag(MainViews.databases)
                    
                    Label("About", systemImage: "info.circle")
                        .tag(MainViews.about)
                }
            }
        } detail: {
            switch sidebarSelection {
            case .extract:
                ExtractionView(
                    extractionModel: extractionModel,
                    progressPublisher: progressPublisher
                )
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
    }
}

#Preview {
    @StateObject  var settingsStore = SettingsStore()

    @StateObject var progressPublisher = ProgressPublisher(
        progress: Progress(totalUnitCount: 100)
    )

    @StateObject var extractionModel = ExtractionModel(
        settingsStore: settingsStore,
        progressPublisher: progressPublisher
    )

    return ContentView(
        extractionModel: extractionModel,
        progressPublisher: progressPublisher
    )
    .environmentObject(settingsStore)
}
