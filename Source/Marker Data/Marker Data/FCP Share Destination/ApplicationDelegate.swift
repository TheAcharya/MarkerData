//
//  ApplicationDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 13/01/2024.
//

import Foundation
import Cocoa

class ApplicationDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            // ------------------------------------------------------------
            // Media File & FCPXML Received:
            // ------------------------------------------------------------
            NSLog("File Received: \(url.path)")
            
            // ------------------------------------------------------------
            // Create an alert:
            // ------------------------------------------------------------
            let alert = NSAlert()
            alert.messageText = "File Received"
            alert.informativeText = "File Received: \(url.path)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            
            // ------------------------------------------------------------
            // Display the alert:
            // ------------------------------------------------------------
            alert.runModal()
        }
    }
}
