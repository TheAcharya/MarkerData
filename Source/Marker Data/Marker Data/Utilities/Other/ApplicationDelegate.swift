//
//  ApplicationDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 13/01/2024.
//

import Foundation
import AppKit
import Sparkle

class ApplicationDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
    var updaterController: SPUStandardUpdaterController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: nil)
    }

    @objc func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        // Notify SwiftUI view about the update
        NotificationCenter.default.post(name: .updateAvailable, object: nil)
    }
}
