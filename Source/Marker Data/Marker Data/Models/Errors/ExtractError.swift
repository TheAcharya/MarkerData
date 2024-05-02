//
//  ExtractError.swift
//  Marker Data
//
//  Created by Milán Várady on 25/12/2023.
//

import Foundation

enum ExtractError: Error {
    case invalidExportDestination
    case exportResultisNil
    case settingsReadError
    case unifiedExportProfileReadError
    case userCancel
    case conflictingNamingAndSource
}

extension ExtractError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidExportDestination:
            "Invalid export destination"
        case .settingsReadError:
            "Failed to read export settings"
        case .unifiedExportProfileReadError:
            "Couldn't read export profile"
        case .userCancel:
            "User initiated cancel"
        case .exportResultisNil:
            "Failed to get export result"
        case .conflictingNamingAndSource:
            "Incompatible Settings Detected. The 'Naming Mode' is set to 'Notes', which conflicts with 'Marker Source' set to 'Marker and Captions' or Captions. Please adjust your settings to resolve this conflict."
        }
    }
}
