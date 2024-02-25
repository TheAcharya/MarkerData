//
//  FileCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 20/01/2024.
//

import Foundation
import SwiftUI

struct FileCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .importExport) {
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
