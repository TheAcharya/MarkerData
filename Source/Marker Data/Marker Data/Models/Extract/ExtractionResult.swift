//
//  ExtractionResult.swift
//  Marker Data
//
//  Created by Milán Várady on 25/11/2023.
//

import Foundation

struct ExtractionFailure: Codable, Identifiable, Hashable {
    let url: URL
    let exitStatus: ExtractionExitStatus
    
    var id: URL {
        return url
    }
}

enum ExtractionExitStatus: String, Codable {
    case failedToExtract = "Failed to extract data"
    case failedToUpload = "Failed to upload to database"
}
