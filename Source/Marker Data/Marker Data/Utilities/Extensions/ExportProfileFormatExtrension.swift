//
//  ExportProfileFormatExtrension.swift
//  Marker Data
//
//  Created by Milán Várady on 04/12/2023.
//

import Foundation
import MarkersExtractor

extension ExportProfileFormat {
    public var extractOnlyName: String {
        switch self {
        case .airtable:
            return "Airtable (no upload)"
        case .midi:
            return "MIDI file"
        case .notion:
            return "Notion (no upload)"
        case .csv:
            return "CSV file"
        case .tsv:
            return "TSV file"
        }
    }
    
    public static var allExtractOnlyNames: [String] {
        Self.allCases.map( { $0.extractOnlyName })
    }
    
    init?(extractOnlyName: String) {
        switch extractOnlyName {
        case "Airtable (no upload)":
            self = .airtable
        case "MIDI file":
            self = .midi
        case "Notion (no upload)":
            self = .notion
        case "CSV file":
            self = .csv
        case "TSV file":
            self = .tsv
        default:
            return nil
        }
    }
}
