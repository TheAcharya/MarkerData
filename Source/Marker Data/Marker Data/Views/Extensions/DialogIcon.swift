//
//  DialogIcon.swift
//  Marker Data
//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Shared app icon for About, Workflow Extension, and SwiftUI alerts;
//  Icon Composer Marker-Data.icon. Do not flatten the layer PNG into AppIconSingle.
//

import AppKit
import SwiftUI

@MainActor
enum MarkerDataAppIcon {
    /// Compiled Icon Composer `Marker-Data.icon` (`ASSETCATALOG_COMPILER_APPICON_NAME` = Marker-Data).
    private static var displayIcon: NSImage {
        if isWorkflowExtension, let hostIcon = iconFromContainingMarkerDataApp {
            return hostIcon
        }

        if let named = NSImage(named: "Marker-Data") {
            return named
        }

        return NSApplication.shared.applicationIconImage
    }

    /// Workflow Extension.appex lives in `Marker Data.app/Contents/PlugIns/`.
    private static var isWorkflowExtension: Bool {
        Bundle.main.bundleURL.pathExtension == "appex"
    }

    /// Main app Icon Composer icon. Do not use this appex’s `AppIcon.appiconset`
    /// (`applicationIconImage` in the extension is that catalog, or Final Cut Pro).
    private static var iconFromContainingMarkerDataApp: NSImage? {
        let hostApp = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        guard hostApp.pathExtension == "app" else { return nil }

        if let hostBundle = Bundle(url: hostApp),
           let named = hostBundle.image(forResource: "Marker-Data") {
            return named
        }

        return NSWorkspace.shared.icon(forFile: hostApp.path)
    }

    /// Image for SwiftUI `.dialogIcon` (alerts / confirmation dialogs).
    static var dialogImage: Image {
        Image(nsImage: displayIcon)
    }

    /// Unsized icon content. Callers apply layout (About 200×200, Workflow Extension 100×100).
    static func image() -> some View {
        Image(nsImage: displayIcon)
            .resizable()
            .scaledToFit()
    }
}

extension View {
    /// Applies the Marker Data app icon to alerts and confirmation dialogs.
    @MainActor
    func appDialogIcon() -> some View {
        self.dialogIcon(MarkerDataAppIcon.dialogImage)
    }
}
