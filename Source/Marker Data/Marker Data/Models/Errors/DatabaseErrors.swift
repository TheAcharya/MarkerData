//
//  DatabaseErrors.swift
//  Marker Data
//
//  Created by Milán Várady on 23/11/2023.
//

import Foundation

enum DatabaseValidationError: Error {
    case emptyName
    case emptyCredentials
    case nameAlreadyExists
    case illegalName
}

extension DatabaseValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyName:
            "Empty profile name"
        case .emptyCredentials:
            "Empty profile credentials"
        case .nameAlreadyExists:
            "A profile with the same name already exists"
        case .illegalName:
            "This name is not allowed"
        }
    }
}

enum DatabaseRemoveError: Error {
    case profileDoesntExist
}

enum DatabaseUploadError: Error {
    case notionNoToken
    case notionUploadError
    case csv2notionExecutableNotFound
}

enum DatabaseProfileDuplicationError: Error {
    case noProfileFound
}
