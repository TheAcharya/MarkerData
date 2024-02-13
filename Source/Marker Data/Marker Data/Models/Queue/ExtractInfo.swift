//
//  ExtractInfo.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import Foundation
import MarkersExtractor

struct ExtractInfo: Codable, Identifiable {
    let jsonURL: URL
    let creationDate: Date
    let profile: DatabasePlatform
    
    var id: URL {
        jsonURL
    }
    
    init(jsonURL: URL, profile: DatabasePlatform) {
        self.jsonURL = jsonURL
        self.creationDate = Date()
        self.profile = profile
    }
    
    init(exportResult: ExportResult) throws {
        self.profile = switch exportResult.profile {
        case .notion:
            DatabasePlatform.notion
        case .airtable:
            DatabasePlatform.airtable
        default:
            throw ExtractInfoError.invalidProfile
        }
        
        guard let jsonURL = exportResult.jsonManifestPath else {
            throw ExtractInfoError.invalidJSONPath
        }
        
        self.jsonURL = jsonURL
        
        self.creationDate = Date()
    }
    
    public func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(self)
        
        try data.write(to: url)
    }
}

enum ExtractInfoError: Error {
    case invalidProfile
    case invalidJSONPath
}
