//
//  UnifiedExportProfile.swift
//  Marker Data
//
//  Created by Milán Várady on 04/01/2024.
//

import Foundation
import MarkersExtractor

/// Holds both extract profile and database profile
///
/// Selected profile is saved to application support
struct UnifiedExportProfile: Codable, Hashable, Identifiable, Equatable {
    let displayName: String
    let extractProfile: ExportProfileFormat
    let databaseProfileName: String
    let exportProfileType: ExportProfileType
    
    var id: Self {
        self
    }
    
    /// Returns the no upload extraction proifles as a list of ``UnifiedExportProfile``
    public static var noUploadProfiles: [UnifiedExportProfile] {
        let unifiledProfiles = ExportProfileFormat.allCasesInUIOrder.map { exportFormat in
            UnifiedExportProfile(
                displayName: exportFormat.extractOnlyName,
                extractProfile: exportFormat.self,
                databaseProfileName: "",
                exportProfileType: .extractOnly
            )
        }
        
        return unifiledProfiles
    }
    
    /// Icon name
    public var iconImageName: String {
        switch self.extractProfile {
        case .airtable:
            return "AirtableLogo"
        case .csv:
            return "NumbersIcon"
        case .midi:
            return "MusicIcon"
        case .notion:
            return "NotionLogo"
        case .tsv:
            return "NumbersIcon"
        case .youtube:
            return "YouTubeLogo"
        case .xlsx:
            return "ExcelIcon"
        case .json:
            return ""
        }
    }
}

enum ExportProfileType: String, Codable {
    case extractOnly
    case extractAndUpload
}
