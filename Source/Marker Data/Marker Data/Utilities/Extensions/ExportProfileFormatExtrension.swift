//
//  ExportProfileFormatExtrension.swift
//  Marker Data
//
//  Created by Milán Várady on 04/12/2023.
//

import Foundation
import MarkersExtractor

extension ExportProfileFormat: Codable {
    static var allCasesInUIOrder: [ExportProfileFormat] {
        let inUIOrder = [Self.csv, Self.tsv, Self.xlsx, Self.midi, Self.markdown, Self.youtube, Self.compressor, Self.notion, Self.airtable]
        assert(inUIOrder.count == Self.allCases.count - 1, "ExportProfileFormat.allCasesInUIOrder has invalid number of elements")
        return inUIOrder
    }
    
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
        case .youtube:
            return "YouTube Chapters"
        case .xlsx:
            return "Excel"
        case .compressor:
            return "Compressor Chapters"
        case .markdown:
            return "Markdown List"
        case .json:
            return "JSON"
        }
    }
    
    public static var allExtractOnlyNames: [String] {
        Self.allCases.map( { $0.extractOnlyName })
    }
}
