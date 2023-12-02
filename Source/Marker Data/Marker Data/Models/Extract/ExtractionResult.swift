//
//  ExtractionResult.swift
//  Marker Data
//
//  Created by Milán Várady on 25/11/2023.
//

import Foundation

struct ExtractionFailure {
    let url: URL
    let exitStatus: ExtractionExitStatus
}

enum ExtractionExitStatus: String {
    case failedToUpload = "Failed to upload to database"
}
