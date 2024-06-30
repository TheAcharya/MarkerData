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
        updaterController.updater.checkForUpdatesInBackground()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // Notify SwiftUI view if update is available
    func bestValidUpdate(in appcast: SUAppcast, for updater: SPUUpdater) -> SUAppcastItem? {
        // Compare current build number with the best available one
        if let buildNumberString = appcast.items.first?.versionString,
           let bestAvaiableBuildNumber = Int(buildNumberString),
           let currentBuildNumber = Int(Bundle.main.buildNumber) {

            if bestAvaiableBuildNumber > currentBuildNumber {
                // Notify SwiftUI view about the update
                NotificationCenter.default.post(name: .updateAvailable, object: nil)
            }
        }

        return SUAppcastItem.empty()
    }

    // For some reason this function is not called consistently so we use the bestValidUpdate instead
//    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
//        // Notify SwiftUI view about the update
//        NotificationCenter.default.post(name: .updateAvailable, object: nil)
//    }
}
