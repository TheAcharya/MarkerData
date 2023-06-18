//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import CoreData

struct ConfigurationSettingsView: View {
    
    @EnvironmentObject var settingsStore: SettingsStore
    
    @Environment(\.managedObjectContext)  var viewContext
    @State private var showPopover: Bool = false
    //@State private var selection = Set<Configuration>()
    @State private var selectedItems = Set<UUID>()
    @State private var idMap = [Configuration.ID: Configuration]()
    //@State private var selection: Set<Configuration> = []
    //@State private var selection : Configuration.ID?
    //@Binding var selection: Set<Configuration>
   

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Configuration.isActiveString, ascending: true)])
    var configurations: FetchedResults<Configuration>
    @State private var sortOrder = [KeyPathComparator(\Configuration.isActiveString)]
    
    
    func newConfigurationDialog() {
        let msg = NSAlert()
        msg.addButton(withTitle: "Ok")
        msg.addButton(withTitle: "Cancel")
        msg.messageText = "New Configuration"
        msg.informativeText = "Enter the name of the configuration"

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = ""

        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()

        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            if !txt.stringValue.isEmpty {
                let newConfiguration = Configuration(context: viewContext)
                newConfiguration.name = txt.stringValue
                newConfiguration.isActiveString = "Inactive"
                newConfiguration.isActive = false
                do {
                    try viewContext.save()
                } catch {
                    print("Error saving = \(error.localizedDescription)")

                }
            }
        }
    }
    
    func removeConfig(at offsets: IndexSet) {
        for index in offsets {
            let config = configurations[index]
            viewContext.delete(config)
            do {
                try viewContext.save()
            } catch {
                print("error= \(error.localizedDescription)")
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Table(configurations, sortOrder: $sortOrder)  {
                TableColumn("Configuration Name", value: \.name!) { configuration in
                    Text(configuration.name ?? "Unknown name").tag(configuration.objectID)
                }
                    
                    TableColumn("Active", value: \.isActiveString!)
                }
                
                
                Button(action: {}) {
                    Text("Export Marker Data Configurations")
                }
                //Button To Import Marker Data Settings
                Button(action: {}) {
                    Text("Import Marker Data Configurations")
                }
                //Button To Load Default Marker Data Settings
                Button(action: {}) {
                    Text("Load Defaults")
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        Spacer()
            .navigationTitle("Configuration Settings")
    }
}

struct ConfigurationSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        ConfigurationSettingsView().environmentObject(settingsStore)
            // .environment(
            //     \.managedObjectContext,
            //      PersistenceController.preview.container.viewContext
            // )
    }
}
