//
//  ExportProfileFormatExtrension.swift
//  Marker Data
//
//  Created by Milán Várady on 04/12/2023.
//

import Foundation
import MarkersExtractor

extension ExportProfileFormat: Codable {
    public var extractOnlyName: String {
        switch self {
        case .airtable:
            return "Airtable (No Upload)"
        case .midi:
            return "MIDI"
        case .notion:
            return "Notion (No Upload)"
        case .csv:
            return "CSV"
        case .tsv:
            return "TSV"
        }
    }
    
    public static var allExtractOnlyNames: [String] {
        Self.allCases.map( { $0.extractOnlyName })
    }
}
