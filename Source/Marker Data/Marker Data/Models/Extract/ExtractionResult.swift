//
//  ExtractionResult.swift
//  Marker Data
//
//  Created by Milán Várady on 25/11/2023.
//

import Foundation

struct ExtractionFailure: Codable, Identifiable, Hashable {
    let url: URL
    let exitStatus: ExportFailPhase
    let errorMessage: String
    
    var id: URL {
        return url
    }
}

enum ExportFailPhase: String, Codable {
    case failedToExtract = "Extract error"
    case failedToUpload = "Upload error"
}
