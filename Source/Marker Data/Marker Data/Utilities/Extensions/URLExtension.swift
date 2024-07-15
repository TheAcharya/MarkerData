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
            .appendingPathComponent("Marker Data", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Configurations
    public static var configurationsFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Configurations", conformingTo: .folder)
    }

    /// ~/Library/Application Support/Marker Data/preferences.json
    public static var preferencesJSON: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("preferences", conformingTo: .json)
    }

    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles
    public static var databaseProfilesFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Database Profiles", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Notion
    public static var notionProfilesFolder: URL {
        Self.databaseProfilesFolder
            .appendingPathComponent("Notion", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Airtable
    public static var airtableProfilesFolder: URL {
        Self.databaseProfilesFolder
            .appendingPathComponent("Airtable", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Dropbox
    public static var dropboxFolder: URL {
        Self.databaseProfilesFolder
            .appendingPathComponent("Dropbox", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Dropbox/dopbox_token.json
    public static var dropboxTokenJSON: URL {
        Self.dropboxFolder
            .appendingPathComponent("dropbox_token", conformingTo: .json)
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
    
    /// Path to DefaultConfiguration.json
    public static var defaultConfigurationJSON: URL? {
        return Bundle.main.url(forResource: "DefaultConfiguration", withExtension: "json")
    }
    
    /// Path to /Applications/Marker Data.app
    public static var markerDataApp: URL {
        return Self.applicationDirectory
            .appendingPathComponent("Marker Data.app", conformingTo: .application)
    }
    
    func conformsToType(_ types: [UTType]) -> Bool {
        let fileExtensions = types
            .compactMap { $0.preferredFilenameExtension }
        
        return fileExtensions.contains(pathExtension)
    }
}
