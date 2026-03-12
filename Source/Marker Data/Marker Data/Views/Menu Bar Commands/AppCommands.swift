//
//  AppCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import Foundation
import SwiftUI
import Sparkle

struct AppCommands: Commands {
    @Binding var sidebarSelection: MainViews
    @Binding var updateAvailable: Bool
    let updaterController: SPUStandardUpdaterController

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Marker Data") {
                deminiaturizeAllWindows()
                sidebarSelection = .about
            }
        }

        CommandGroup(before: .systemServices) {
            CheckForUpdatesView(updater: updaterController.updater) {
                Label("Check for Updates...", systemImage: "arrow.trianglehead.clockwise.rotate.90")
            }
            .badge(updateAvailable ? "Update Available" : nil)
        }
    }
}
