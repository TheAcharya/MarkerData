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
    case missingJsonFile
    case notionNoToken
    case notionUploadError
    case csv2notionExecutableNotFound
}

extension DatabaseUploadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingJsonFile:
            "Couldn't locate json"
        case .notionNoToken:
            "Missing notion API token"
        case .notionUploadError:
            "Failed to upload to Notion"
        case .csv2notionExecutableNotFound:
            "CSV2Notion executable not found"
        }
    }
}

enum DatabaseProfileDuplicationError: Error {
    case noProfileFound
}