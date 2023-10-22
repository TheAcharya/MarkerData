//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import AppUpdater

@main
struct Marker_DataApp: App {
    @StateObject private var settings: SettingsContainer
    @StateObject private var progressPublisher: ProgressPublisher
    @StateObject private var extractionModel: ExtractionModel
    @StateObject var configurationsModel: ConfigurationsModel

    let persistenceController = PersistenceController.shared
    
    /// Controlled from the menu bar
    @State var selectedConfiguration: String

    init() {
        let settings = SettingsContainer()
        
        let progress = Progress(totalUnitCount: 0)
        let progressPublisher = ProgressPublisher(progress: progress)
        
        let extractionModel = ExtractionModel(
            settings: settings,
            progressPublisher: progressPublisher
        )
        
        let configurationsModel = ConfigurationsModel()
        
        self._settings = StateObject(wrappedValue: settings)
        self._progressPublisher = StateObject(wrappedValue: progressPublisher)
        self._extractionModel = StateObject(wrappedValue: extractionModel)
        self._configurationsModel = StateObject(wrappedValue: configurationsModel)
        
        self._selectedConfiguration = State(wrappedValue: configurationsModel.activeConfiguration)
    }
    
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {

            // MARK: ContentView
            ContentView(
                extractionModel: self.extractionModel,
                progressPublisher: progressPublisher
            )
            .environmentObject(settings)
            .environmentObject(configurationsModel)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            // Force Dark Mode On Content View
            .preferredColorScheme(.dark)
            // Set Main Window Min And Max Size
            .frame(
                minWidth: 750,
                idealWidth: 750,
                maxWidth: .infinity,
                minHeight: 400,
                idealHeight: 400,
                maxHeight: .infinity,
                alignment: .center
            )
            // Change configuration (controlled from the menu bar)
            .onChange(of: selectedConfiguration) { newConfig in
                do {
                    try configurationsModel.loadConfiguration(configurationName: newConfig, settings: settings)
                } catch {
                    print("Failed to load configuration: \(newConfig)")
                }
            }
            .onChange(of: configurationsModel.activeConfiguration) {
                selectedConfiguration = $0
            }
        }
        
        // Customise Menu Bar Commands
        .commands {
            // Removes New Window Menu Item
            CommandGroup(replacing: .newItem) {}
            // Removes Toolbar Menu Items
            CommandGroup(replacing: .toolbar) {}
            
            SidebarCommands()
            
            ConfigurationCommands(
                configurationsModel: configurationsModel,
                settings: settings,
                selectedConfiguration: $selectedConfiguration
            )
            
            DatabaseCommands()
            HelpCommands()
        }
    }
}
