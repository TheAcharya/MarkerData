//
//  ExtractError.swift
//  Marker Data
//
//  Created by Milán Várady on 25/12/2023.
//

import Foundation

enum ExtractError: Error {
    case invalidExportDestination
    case settingsReadError
}

extension ExtractError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidExportDestination:
            "Invalid export destination"
        case .settingsReadError:
            "Failed to read export settings"
        }
    }
}