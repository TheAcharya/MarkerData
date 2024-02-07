//
//  DatabasePlatform.swift
//  Marker Data
//
//  Created by Milán Várady on 05/02/2024.
//

import Foundation
import MarkersExtractor

enum DatabasePlatform: String, Codable, CaseIterable, Identifiable {
    case notion = "Notion"
    case airtable = "Airtable"
    
    var id: Self { self }
    
    var asExportProfile: ExportProfileFormat {
        switch self {
        case .notion:
            ExportProfileFormat.notion
        case .airtable:
            ExportProfileFormat.airtable
        }
    }
}
