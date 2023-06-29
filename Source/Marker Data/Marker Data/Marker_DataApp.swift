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
    
    // @Environment(\.openWindow) var openWindow

    @StateObject private var settingsStore = SettingsStore()
    
    let persistenceController = PersistenceController.shared
    
    let appName: String = {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleDisplayName"
        ) as! String
    }()

    //Link App Delegate To SwiftUI App Lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {
            let progress = Progress(totalUnitCount: 100)
            let progressPublisher = ProgressPublisher(progress: progress)
            ContentView(progressPublisher: progressPublisher)
                .environmentObject(settingsStore)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            //Force Dark Mode On Content View
                .preferredColorScheme(.dark)
            //Set Main Window Min And Max Size
                .frame(minWidth: 750, idealWidth: 750, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity, alignment: .center)
            // Run Code On View Appear On Screen
                .onAppear() {
                    appDelegate.userRequestedAnExplicitUpdateCheck()
                }
        }
        // Add Settings Menu Bar Item And Pass In A View
        Settings {
            SettingsView()
                .environmentObject(settingsStore)
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
                // Force Dark Mode On Settings View
                .preferredColorScheme(.dark)
            
        }
        
        //Customise Menu Bar Commands
        .commands {
            
            SidebarCommands()

            CommandGroup(replacing: .appInfo) {
                Button("About \(appName)") {

                    print("Open About in settings")

                    settingsStore.settingsSection = .about

                    if #available(macOS 13, *) {
                        NSApp.sendAction(
                            Selector(("showSettingsWindow:")),
                            to: nil,
                            from: nil
                        )
                    } else {
                        NSApp.sendAction(
                            Selector(("showPreferencesWindow:")),
                            to: nil,
                            from: nil
                        )
                    }


                }
            }

            //Removes New Window Menu Item
            CommandGroup(replacing: .newItem) {}
            //Removes Toolbar Menu Items
            CommandGroup(replacing: .toolbar) {}
            //Add Check For Updates Button
            CommandGroup(after: .appSettings) {
                Button(action: {}) {
                    Text("Check For Update...")
                }
            }
            //Add Help And Debug Menu Buttons
            CommandGroup(after: .help) {
                //Button To Be Sent To App Website
                Button(action: {}) {
                    Text("Website")
                }
                //Button To Access The User Guide
                Button(action: {}) {
                    Text("User Guide")
                }
                //Button To Send App Feedback
                Button(action: {}) {
                    Text("Send Feedback")
                }
                //Button To Access App Discussion Page
                Button(action: {}) {
                    Text("Discussions")
                }
                //Debug Menu
                Menu("Debug") {
                    //Button To Open Debug Console
                    Button(action: {}) {
                        Text("Open Debug Console")
                    }
                    //Button To Open The App Log Folder
                    Button(action: {}) {
                        Text("Open Log Folder")
                    }
                }
            }
            //Add Custom Configurations Menu
            CommandMenu("Configurations") {
                //Set Default Configurations Button
                Button(action: {}) {
                    Text("Defaults")
                }
                //Button To Set Configuration Name 1
                Button(action: {}) {
                    Text("Name 1")
                }
                //Button To Set Configuration Name 2
                Button(action: {}) {
                    Text("Name 2")
                }
            }
            //Add Custom Databases Menu
            CommandMenu("Databases") {
                //Upload Submenu
                Menu("Upload") {
                    //Button To Enable Upload
                    Button(action: {}) {
                        Text("Enable")
                    }
                    //Button To Disable Upload
                    Button(action: {}) {
                        Text("Disable")
                    }
                }
                //Airtable Submenu
                Menu("Airtable") {
                    //Select Profile A Button
                    Button(action: {}) {
                        Text("Profile A")
                    }
                    //Select Profile B Button
                    Button(action: {}) {
                        Text("Profile B")
                    }
                    //Select Profile C Button
                    Button(action: {}) {
                        Text("Profile C")
                    }
                }
                //Notion Submenu
                Menu("Notion") {
                    //Select Profile A Button
                    Button(action: {}) {
                        Text("Profile A")
                    }
                    //Select Profile B Button
                    Button(action: {}) {
                        Text("Profile B")
                    }
                    //Select Profile C Button
                    Button(action: {}) {
                        Text("Profile C")
                    }
                }
            }
        }
        // .modify { scene in
        //     if #available(macOS 13.0, *) {
        //         scene.commandsReplaced {
        //             CommandGroup(replacing: .appInfo) {
        //                 Button("About \(appName)") {
        //                     print("About")
        //                 }
        //             }
        //         }
        //     }
        // }

    }
    
}

//Init App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    
    //Declare Repo To Update From
    let updater = AppUpdater(owner: "TheAcharya", repo: "MarkerData")

    //Function To Request App Update Check
    func userRequestedAnExplicitUpdateCheck() {
        updater.check().catch(policy: .allErrors) { error in
            if error.isCancelled {
                print("Cancelled")
            } else {
                print("\(error.localizedDescription)")
            }
        }
    }
}
