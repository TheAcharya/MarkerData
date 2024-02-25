//
//  ConfigurationErrors.swift
//  Marker Data
//
//  Created by Milán Várady on 10/10/2023.
//

import Foundation

enum ConfigurationSaveError: Error {
    case nameTooLong
    case jsonSerializationError
    case fileCreationError
    case nameAlreadyExists
    case illegalName
    case duplicationError
}

enum ConfigurationLoadError: Error {
    case fileDoesntExists
    case emptyConfigurationName
    case jsonParseError
}

enum StoreLocateError: Error {
    case storeNotFound
}

extension ConfigurationSaveError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nameTooLong:
            "Name too long"
        case .jsonSerializationError:
            "Couldn't serialize configurations"
        case .fileCreationError:
            "Couldn't create configuration file"
        case .nameAlreadyExists:
            "A configuration with the same name already exists"
        case .illegalName:
            "Configuration name not allowed"
        case .duplicationError:
            "Failed to duplicate configuration"
        }
    }
}
