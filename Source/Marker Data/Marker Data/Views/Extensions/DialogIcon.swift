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

enum MarkerDataAppIcon {
    /// Compiled Icon Composer `Marker-Data.icon` (`ASSETCATALOG_COMPILER_APPICON_NAME` = Marker-Data).
    /// Prefer the named asset from this bundle so the Workflow Extension (hosted in Final Cut Pro)
    /// does not pick up the host’s `applicationIconImage`.
    private static var displayIcon: NSImage {
        if let named = NSImage(named: "Marker-Data") {
            return named
        }
        return NSApplication.shared.applicationIconImage
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
    func appDialogIcon() -> some View {
        self.dialogIcon(MarkerDataAppIcon.dialogImage)
    }
}
