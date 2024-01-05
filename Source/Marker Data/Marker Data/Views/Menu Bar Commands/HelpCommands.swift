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
            Link("Website", destination: URL(string: "https://markerdata.theacharya.co")!)
            Link("Source Code", destination: URL(string: "https://github.com/TheAcharya/MarkerData")!)
            
            Divider()
            
            Link("Release Notes", destination: URL(string: "https://markerdata.theacharya.co/release-notes/")!)
            Link("About Marker Data", destination: URL(string: "https://markerdata.theacharya.co/credits/")!)
            
            Divider()
            
            Link("Send Feedback", destination: URL(string: "https://github.com/TheAcharya/MarkerData/issues")!)
            Link("Discussions", destination: URL(string: "https://github.com/TheAcharya/MarkerData/discussions")!)
            
            Divider()
            
            // Open Console
            Button("Debug") {
                guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Console") else { return }

                let path = "/bin"
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.arguments = [path]
                NSWorkspace.shared.openApplication(at: url,
                                                   configuration: configuration,
                                                   completionHandler: nil)
            }
        }
    }
}
