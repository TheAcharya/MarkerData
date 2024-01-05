//
//  UnifiedExportProfile.swift
//  Marker Data
//
//  Created by Milán Várady on 04/01/2024.
//

import Foundation
import MarkersExtractor

/// Holds both extract profile (``ExportProfileFormat``) and database profile
///
/// Selected profile is saved to application support
struct UnifiedExportProfile: Codable, Hashable, Identifiable {
    let displayName: String
    let extractProfile: ExportProfileFormat
    let databaseProfileName: String
    let exportProfileType: ExportProfileType
    
    var id: Self {
        self
    }
    
    /// Saves a ``UnifiedExportProfile`` to disk
    public func save() throws {
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(self)
        
        try data.write(to: URL.unifiedExportProfile)
    }
    
    public static func defaultProfile() -> Self {
        return UnifiedExportProfile(
            displayName: "CSV",
            extractProfile: .csv,
            databaseProfileName: "",
            exportProfileType: .extractOnly
        )
    }
    
    /// Loads the ``UnifiedExportProfile`` from disk
    public static func load() -> UnifiedExportProfile? {
        // Return default if file desn't exists
        if !URL.unifiedExportProfile.fileExists {
            return UnifiedExportProfile.defaultProfile()
        }
        
        let decoder = JSONDecoder()
        
        do {
            // Try to decode data
            let data = try Data(contentsOf: URL.unifiedExportProfile)
            let decoded = try decoder.decode(UnifiedExportProfile.self, from: data)
            
            return decoded
        } catch {
            print("Failed to decode UnifiedExportProfile")
            return nil
        }
    }
    
    /// Returns the no upload extraction proifles as a list of ``UnifiedExportProfile``
    public static var noUploadProfiles: [UnifiedExportProfile] {
        let unifiledProfiles = ExportProfileFormat.allCases.map { exportFormat in
            UnifiedExportProfile(
                displayName: exportFormat.extractOnlyName,
                extractProfile: exportFormat.self,
                databaseProfileName: "",
                exportProfileType: .extractOnly
            )
        }
        
        return unifiledProfiles
    }
}

enum ExportProfileType: String, Codable {
    case extractOnly
    case extractAndUpload
}
