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
    static var markerDataLibraryFolder: URL {
        Self.applicationSupportDirectory
            .appendingPathComponent("Marker Data", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Configurations
    static var configurationsFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Configurations", conformingTo: .folder)
    }

    /// ~/Library/Application Support/Marker Data/preferences.json
    static var preferencesJSON: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("preferences", conformingTo: .json)
    }

    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles
    static var databaseProfilesFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Database Profiles", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Notion
    static var notionProfilesFolder: URL {
        Self.databaseProfilesFolder
            .appendingPathComponent("Notion", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Airtable
    static var airtableProfilesFolder: URL {
        Self.databaseProfilesFolder
            .appendingPathComponent("Airtable", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Dropbox
    static var dropboxFolder: URL {
        Self.databaseProfilesFolder
            .appendingPathComponent("Dropbox", conformingTo: .folder)
    }
    
    /// Path to ~/Library/Application Support/Marker Data/Database/Profiles/Dropbox/dopbox_token.json
    static var dropboxTokenJSON: URL {
        Self.dropboxFolder
            .appendingPathComponent("dropbox_token", conformingTo: .json)
    }
    
    /// Path to ~/Library/Preferences/Marker Data/Logs
    static var logsFolder: URL {
        Self.markerDataLibraryFolder
            .appendingPathComponent("Logs", conformingTo: .folder)
    }
    
    /// Path to ~/Movies/Marker Data Cache
    static var FCPExportCacheFolder: URL {
        Self.moviesDirectory
            .appendingPathComponent("Marker Data Cache", conformingTo: .folder)
    }
    
    /// Path to ~/Movies/Marker Data Cache/WorkflowExtensionExport.fcpxml
    static var workflowExtensionExportFCPXML: URL {
        Self.FCPExportCacheFolder
            .appendingPathComponent("WorkflowExtensionExport.fcpxml", conformingTo: .fcpxml)
    }
    
    /// Path to DefaultConfiguration.json
    static var defaultConfigurationJSON: URL? {
        return Bundle.main.url(forResource: "DefaultConfiguration", withExtension: "json")
    }
    
    /// Path to /Applications/Marker Data.app
    static var markerDataApp: URL {
        return Self.applicationDirectory
            .appendingPathComponent("Marker Data.app", conformingTo: .application)
    }

    static var WebKitCache: URL {
        return Self.libraryDirectory
            .appending(components: "WebKit", "co.theacharya.MarkerData")
    }

    func conformsToType(_ types: [UTType]) -> Bool {
        let fileExtensions = types
            .compactMap { $0.preferredFilenameExtension }
        
        return fileExtensions.contains(pathExtension)
    }
}
