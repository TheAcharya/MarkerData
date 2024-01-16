//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

@main
struct Marker_DataApp: App {
    // Environment objects
    @StateObject private var settings: SettingsContainer
    
    @StateObject private var extractionModel: ExtractionModel
    
    @StateObject var configurationsModel: ConfigurationsModel
    
    @StateObject var databaseManager: DatabaseManager
    
    /// Currently selected detail view in the sidebar
    @State var sidebarSelection: MainViews = .extract

    let persistenceController = PersistenceController.shared
    
    @State var showLibraryFolderCreationAlert = false
    
    let openEventHandler = OpenEventHandler()

    init() {
        let settings = SettingsContainer()
        let databaseManager = DatabaseManager()
        
        let extractionModel = ExtractionModel(
            settings: settings,
            databaseManager: databaseManager
        )
        
        let configurationsModel = ConfigurationsModel()
        
        self._settings = StateObject(wrappedValue: settings)
        self._extractionModel = StateObject(wrappedValue: extractionModel)
        self._configurationsModel = StateObject(wrappedValue: configurationsModel)
        self._databaseManager = StateObject(wrappedValue: databaseManager)
        
        openEventHandler.setupHandler()
    }
    
//    @NSApplicationDelegateAdaptor(ApplicationDelegate.self) var appDelegate
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {
            // MARK: ContentView
            ContentView(
                extractionModel: self.extractionModel,
                sidebarSelection: $sidebarSelection
            )
            .environmentObject(settings)
            .environmentObject(configurationsModel)
            .environmentObject(databaseManager)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            // Force Dark Mode On Content View
            .preferredColorScheme(.dark)
            // Set fix window size
            .frame(width: WindowSize.fullWidth, height: WindowSize.fullHeight)
            .task {
                // Check Library folders and create missing
                do {
                    try await LibraryFolders.checkAndCreateMissing()
                } catch {
                    self.showLibraryFolderCreationAlert = true
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
            
            AppCommands(sidebarSelection: $sidebarSelection)
            
            SidebarCommands()
            
            ConfigurationCommands(
                configurationsModel: configurationsModel,
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
