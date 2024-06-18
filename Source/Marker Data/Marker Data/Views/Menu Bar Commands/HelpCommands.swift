//
//  HelpCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/10/2023.
//

import SwiftUI
import AppKit

struct HelpCommands: Commands {
    var body: some Commands {
        //Add Help And Debug Menu Buttons
        CommandGroup(replacing: .help) {
            Link("Marker Data Website", destination: URL(string: "https://markerdata.theacharya.co")!)
            Link("Keyboard Shortcuts", destination: URL(string: "https://markerdata.theacharya.co/user-guide/keyboard-shortcuts/")!)
            Link("Troubleshooting", destination: URL(string: "https://markerdata.theacharya.co/troubleshooting/")!)
            
            Divider()
            
            Link("Send Feedback", destination: URL(string: "https://github.com/TheAcharya/MarkerData/issues")!)
            Link("Discussions", destination: URL(string: "https://github.com/TheAcharya/MarkerData/discussions")!)

            Divider()
            
            Link("Release Notes", destination: URL(string: "https://markerdata.theacharya.co/release-notes/")!)
            Link("Source Code", destination: URL(string: "https://github.com/TheAcharya/MarkerData")!)
            Link("Sponsor Marker Data", destination: URL(string: "https://github.com/sponsors/TheAcharya")!)
            Link("About Marker Data", destination: URL(string: "https://markerdata.theacharya.co/credits/")!)
            
            Divider()
            
            Button("Open Logs") {
                Task {
                    // Open log folder in Finder
                    NSWorkspace.shared.open(URL.logsFolder)
                    
                    await LogManager.export()
                }
            }
        }
    }
}
