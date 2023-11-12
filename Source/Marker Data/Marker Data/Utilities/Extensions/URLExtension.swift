//
//  URLExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 08/10/2023.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    /// Path to ~/Library/Application Support/Marker Data
    public static var applicationSupportAppDirectory: URL {
        Self.applicationSupportDirectory.appendingPathComponent(Bundle.main.appName, conformingTo: .directory)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/ Configurations
    public static var configurationsFolder: URL {
        Self.applicationSupportAppDirectory.appendingPathComponent("Configurations", conformingTo: .directory)
    }
    
    /// Path to ~/Library/Preferences/com.TheAcharya.Marker-Data.plist
    public static var preferencesPlistFile: URL {
        Self.libraryDirectory
            .appendingPathComponent("Preferences", conformingTo: .directory)
            .appendingPathComponent(
                Bundle.main.bundleIdentifier ?? "com.TheAcharya.Marker-Data.plist" + ".plist",
                conformingTo: .propertyList)
    }
    
    func conformsToType(_ types: [UTType]) -> Bool {
        let fileExtensions = types
            .map { $0.preferredFilenameExtension }
            .filter { $0 != nil }
        
        return fileExtensions.contains(pathExtension)
    }
}
