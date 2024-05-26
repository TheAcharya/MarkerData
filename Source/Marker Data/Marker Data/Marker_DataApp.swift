//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI
import Sparkle

@main
struct Marker_DataApp: App {
    // Environment objects
    @StateObject private var settings: SettingsContainer
    @StateObject private var extractionModel: ExtractionModel
    @StateObject var databaseManager: DatabaseManager
    @StateObject var queueModel: QueueModel
    
    /// Currently selected detail view in the sidebar
    @State var sidebarSelection: MainViews = .extract
    
    let openEventHandler = OpenEventHandler()
    @State var sidebarSelectionSwitcher: SidebarSelectionSwitcher? = nil
    
    @State var showLibraryFolderCreationAlert = false

    /// Is a new version available through Sparkle
    @State private var isUpdateAvailable = false

    /// Sparkle update controller
    private let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    init() {
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
        
        self._settings = StateObject(wrappedValue: settings)
        self._extractionModel = StateObject(wrappedValue: extractionModel)
        self._databaseManager = StateObject(wrappedValue: databaseManager)
        self._queueModel = StateObject(wrappedValue: queueModel)
    }

//    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) var appDelegate
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {
            // MARK: ContentView
            ContentView(
                extractionModel: self.extractionModel,
                queueModel: self.queueModel,
                sidebarSelection: $sidebarSelection,
                updater: self.updaterController.updater
            )
            .environmentObject(settings)
            .environmentObject(databaseManager)
            // Force Dark Mode On Content View
            .preferredColorScheme(.dark)
            // Set fix window size
            .frame(width: WindowSize.fullWidth, height: WindowSize.fullHeight)
            .task {
                DispatchQueue.main.async {
                    self.sidebarSelectionSwitcher = SidebarSelectionSwitcher(sidebarSelection: $sidebarSelection)
                    self.openEventHandler.setupHandler()
                }
                
                // Check Library folders and create missing
                do {
                    try await LibraryFolders.checkAndCreateMissing()
                } catch {
                    self.showLibraryFolderCreationAlert = true
                }

                // Recieve update available notification
                NotificationCenter.default.addObserver(forName: .updateAvailable, object: nil, queue: .main) { _ in
                    Task {
                        await MainActor.run {
                            self.isUpdateAvailable = true
                        }
                    }
                }
            }
            .alert("Failed to initialize all Library folders", isPresented: $showLibraryFolderCreationAlert) {}
        }
        // Set fix window size
        .windowResizability(.contentSize)
        // Customise Menu Bar Commands
        .commands {
            // Removes New Window Menu Item
            CommandGroup(replacing: .newItem) {}
            
            // Removes Toolbar Menu Items
            CommandGroup(replacing: .toolbar) {}
            
            AppCommands(
                sidebarSelection: $sidebarSelection,
                updateAvailable: $isUpdateAvailable,
                updaterController: updaterController
            )

            FileCommands()
            
            EditCommands()
            
            SidebarCommands()
            
            ConfigurationCommands(
                settings: settings,
                sidebarSelection: $sidebarSelection
            )
            
            HelpCommands()
        }
        
        WindowGroup("Failed Tasks", for: [ExtractionFailure].self) { $failedExtractions in
            FailedExtractionsView(failedExtractions: failedExtractions ?? [])
                .preferredColorScheme(.dark)
        }
    }
}
