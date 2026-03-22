//
//  UninstallerApp.swift
//  Marker Data Uninstaller
//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import SwiftUI

@main
struct UninstallerApp: App {
    var body: some Scene {
        WindowGroup {
            UninstallerView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 340)
        .commandsRemoved()
    }
}
