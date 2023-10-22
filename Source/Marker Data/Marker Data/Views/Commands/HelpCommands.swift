//
//  HelpCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/10/2023.
//

import SwiftUI

struct HelpCommands: Commands {
    var body: some Commands {
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
    }
}
