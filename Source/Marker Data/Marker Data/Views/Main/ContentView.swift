//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
import MarkersExtractor
import Sparkle

struct ContentView: View {
    @EnvironmentObject var settings: SettingsContainer
    @ObservedObject var extractionModel: ExtractionModel
    @ObservedObject var queueModel: QueueModel
    @Binding var sidebarSelection: MainViews
    let updater: SPUUpdater

    /// Used in the toolbar configuration picker
    @State var selectedConfigurationName: String = SettingsStore.defaultName

    // Marker Data installed outside of the Applications folder alert
    @AppStorage("ignoreInstallLocation") var ignoreInstallLocation = false
    @State var showInstallLocationAlert = false

    //Main View Controller
    var body: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                Label("Extract", systemImage: "house")
                    .tag(MainViews.extract)
                
                Label("Queue", systemImage: "tray.and.arrow.up")
                    .tag(MainViews.queue)
                
                Section("Export Settings") {
                    Label("General", systemImage: "gearshape")
                        .tag(MainViews.general)
                    
                    Label("Image", systemImage: "photo")
                        .tag(MainViews.image)
                    
                    Label("Label", systemImage: "tag")
                        .tag(MainViews.label)
                    
                    Label("Configurations", systemImage: "briefcase")
                        .if({
                            return settings.unsavedChanges
                        }()) { view in
                            view
                                .badge(
                                Text("Changed")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(.orange)
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
                case .queue:
                    QueueView(queueModel: queueModel)
                case .general:
                    GeneralSettingsView(updater: updater)
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
        // Configuration picker
        .toolbar {
            Picker("Configuration", selection: $selectedConfigurationName) {
                ForEach(settings.configurations) { store in
                    Text(store.name)
                        .tag(store.name)
                }
            }
            .onAppear {
                selectedConfigurationName = settings.store.name
            }
            // React to changes
            .onReceive(settings.objectWillChange) { _ in
                selectedConfigurationName = settings.store.name
            }
            // Load configuration
            .onChange(of: selectedConfigurationName) { newStoreName in
                do {
                    if let store = settings.findByName(newStoreName) {
                        try settings.load(store)
                    }
                } catch {
                    print("Failed to load config from menu bar")
                }
            }
        }
        // Notify user if Marker Data is installed outisde of the the Applications folder
        .onAppear {
            if let appURL = Bundle.main.resourceURL {
                if !ignoreInstallLocation && !appURL.hasPrefix(url: .applicationDirectory) {
                    showInstallLocationAlert = true
                }
            }
        }
        .alert("Install Location Warning", isPresented: $showInstallLocationAlert) {
            Button("OK") {}
            Button("Don't show again") {
                ignoreInstallLocation = true
            }
        } message: {
            Text("Marker Data must be installed in the Applications folder to run correctly. Please move the application to the Applications folder and try again.")
        }
    }
}

#if compiler(>=6)
#Preview {
    // Declare settings, databaseManager, extractionModel, and queueModel outside the closure
    let settings = SettingsContainer()
    let databaseManager = DatabaseManager(settings: settings)
    
    let extractionModel = ExtractionModel(
        settings: settings,
        databaseManager: databaseManager
    )
    
    let queueModel = QueueModel(
        settings: settings,
        databaseManager: databaseManager
    )

    return ContentView(
        extractionModel: extractionModel,
        queueModel: queueModel,
        sidebarSelection: .constant(.extract),
        updater: SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil).updater
    )
    .environmentObject(settings)
}
#endif
