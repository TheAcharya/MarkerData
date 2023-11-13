//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

@main
struct Marker_DataApp: App {
    @StateObject private var settings: SettingsContainer
    @StateObject private var progressPublisher: ProgressPublisher
    @StateObject private var extractionModel: ExtractionModel
    @StateObject var configurationsModel: ConfigurationsModel
    
    /// Currently selected detail view in the sidebar
    @State var sidebarSelection: MainViews = .extract

    let persistenceController = PersistenceController.shared

    init() {
        let settings = SettingsContainer()
        
        let progressPublisher = ProgressPublisher()
        
        let extractionModel = ExtractionModel(
            settings: settings,
            progressPublisher: progressPublisher
        )
        
        let configurationsModel = ConfigurationsModel()
        
        self._settings = StateObject(wrappedValue: settings)
        self._progressPublisher = StateObject(wrappedValue: progressPublisher)
        self._extractionModel = StateObject(wrappedValue: extractionModel)
        self._configurationsModel = StateObject(wrappedValue: configurationsModel)
    }
    
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {

            // MARK: ContentView
            ContentView(
                extractionModel: self.extractionModel,
                progressPublisher: progressPublisher,
                sidebarSelection: $sidebarSelection
            )
            .environmentObject(settings)
            .environmentObject(configurationsModel)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            // Force Dark Mode On Content View
            .preferredColorScheme(.dark)
            // Set fix window size
            .frame(width: WindowSize.fullWidth, height: WindowSize.fullHeight)
        }
        // Set fix window size
        .windowResizability(.contentSize)
        
        // Customise Menu Bar Commands
        .commands {
            // Removes New Window Menu Item
            CommandGroup(replacing: .newItem) {}
            
            // Removes Toolbar Menu Items
            CommandGroup(replacing: .toolbar) {}
            
            // TODO: Add "Install Share Extension" item
            
            // Replace about
            CommandGroup(replacing: .appInfo) {
                Button("About Marker Data") {
                    sidebarSelection = .about
                }
            }
            
            SidebarCommands()
            
            ConfigurationCommands(
                configurationsModel: configurationsModel,
                settings: settings,
                sidebarSelection: $sidebarSelection
            )
            
            DatabaseCommands()
            HelpCommands()
        }
    }
}
