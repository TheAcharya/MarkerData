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
    public static var markerDataLibraryFolder: URL {
        Self.applicationSupportDirectory
            .appendingPathComponent("Marker Data", conformingTo: .directory)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Configurations
    public static var configurationsFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Configurations", conformingTo: .directory)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles
    public static var databaseProfilesFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Database Profiles", conformingTo: .directory)
    }
    
    /// Path to ~/Library/Preferences/Marker Data/UnifiedExportProfile.json
    public static var unifiedExportProfile: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("UnifiedExportProfile.json", conformingTo: .json)
    }
    
    /// Path to ~/Library/Preferences/Marker Data/roles.json
    public static var rolesJSONStaticPath: URL {
        URL(filePath: "/Users/\(NSUserName())/Library/Application Support/Marker Data/roles.json")
    }
    
    /// Path to ~/Library/Preferences/Marker Data/Logs
    public static var logsFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Logs", conformingTo: .folder)
    }
    
    /// Path to ~/Movies/Marker Data Cache
    public static var FCPExportCacheFolder: URL {
        Self.moviesDirectory
            .appendingPathComponent("Marker Data Cache", conformingTo: .folder)
    }
    
    /// Path to ~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml
    public static var workflowExtensionExportFCPXML: URL {
        Self.FCPExportCacheFolder
            .appendingPathComponent("WorkflowExtensionExport.fcpxml", conformingTo: .fcpxml)
    }
    
    // Path to DefaultConfiguration.json
    public static var defaultConfigurationJSON: URL? {
        return Bundle.main.url(forResource: "DefaultConfiguration", withExtension: "json")
    }
    
    func conformsToType(_ types: [UTType]) -> Bool {
        let fileExtensions = types
            .map { $0.preferredFilenameExtension }
            .filter { $0 != nil }
        
        return fileExtensions.contains(pathExtension)
    }
}
