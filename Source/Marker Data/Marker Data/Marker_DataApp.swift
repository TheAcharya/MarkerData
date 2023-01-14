//
//  Marker_DataApp.swift
//  Marker Data
//
//  Created by Mark Howard on 14/01/2023.
//

import SwiftUI

@main
struct Marker_DataApp: App {
    var body: some Scene {
        //Make Main Window Group To Launch Into
        WindowGroup {
            ContentView()
            //Force Dark Mode On Content View
                .preferredColorScheme(.dark)
            //Set Main Window Min And Max Size
                .frame(minWidth: 750, idealWidth: 750, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity, alignment: .center)
        }
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
        }
    }
}
