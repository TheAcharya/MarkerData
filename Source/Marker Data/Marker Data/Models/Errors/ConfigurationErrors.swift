//
//  ConfigurationErrors.swift
//  Marker Data
//
//  Created by Milán Várady on 10/10/2023.
//

import Foundation

enum ConfigurationInitializationError: Error {
    case failedToReadDirectory
}

enum ConfigurationSaveError: Error {
    case nameTooLong
    case jsonSerializationError
    case fileCreationError
    case nameAlreadyExists
}

enum ConfigurationLoadError: Error {
    case fileDoesntExists
    case emptyConfigurationName
    case jsonParseError
}
