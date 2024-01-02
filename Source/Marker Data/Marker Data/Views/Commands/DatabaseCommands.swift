//
//  DatabaseCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/10/2023.
//

import SwiftUI

struct DatabaseCommands: Commands {
    var body: some Commands {
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
}
