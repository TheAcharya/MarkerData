//
//  FileCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/01/2024.
//
//
//  File menu items replace the New group so system Close / Close All stay last.
//  Do not duplicate Close here.
//

import Foundation
import SwiftUI

struct FileCommands: Commands {
    @Environment(\.openWindow) var openWindow

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open Pagemaker") {
                openWindow(id: "pagemaker")
            }
            .keyboardShortcut("p", modifiers: .command)

            Divider()

            Button("Install FCP Share Destination...") {
                Task {
                    do {
                        try await ShareDestinationInstaller.install()
                    } catch {
                        print("Failed to install FCP Share Destination from menu bar")
                    }
                }
            }

            Divider()

            Button("Show Cache") {
                NSWorkspace.shared.open(URL.FCPExportCacheFolder)
            }

            Button("Clean Cache") {
                LibraryFolders.deleteCache()
            }
            .keyboardShortcut("k", modifiers: .command)
        }
    }
}
