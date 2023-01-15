//
//  Marker_DataApp.swift
//  Marker Data
//
//  Created by Mark Howard on 14/01/2023.
//

import SwiftUI
import AppUpdater

//@available(macOS 13.0, *)
@main
struct Marker_DataApp: App {
    //Link App Delegate To SwiftUI App Lifecycle
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    //Track Opening New Window
    //@Environment(\.openWindow) var openWindow
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {
            ContentView()
            //Force Dark Mode On Content View
                .preferredColorScheme(.dark)
            //Set Main Window Min And Max Size
                .frame(minWidth: 750, idealWidth: 750, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity, alignment: .center)
            //Run Code On View Appear On Screen
                .onAppear() {
                    appDelegate.userRequestedAnExplicitUpdateCheck()
                }
        }
        //Database Preferences
        /*Window("Database Preferences", id: "database-prefs") {
            DatabasePreferences()
        }*/
        //Add Settings Menu Bar Item And Pass In A View
        Settings {
            SettingsView()
            //Force Dark Mode On Settings View
                .preferredColorScheme(.dark)
        }
        //Customise Menu Bar Commands
        .commands {
            //Removes New Window Menu Item
            CommandGroup(replacing: .newItem) {}
            //Removes Toolbar Menu Items
            CommandGroup(replacing: .toolbar) {}
            //Add Custom Tools Menu
            CommandMenu("Tools") {
                //Test Menu Button
                Button(action: {}) {
                    Text("Test Menu Item")
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
                //Display Database Preferences Window
                Button(action: {/*openWindow(id: "database-prefs")*/}) {
                    Text("Database Preferences...")
                }
            }
        }
    }
}

//Init App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    
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
