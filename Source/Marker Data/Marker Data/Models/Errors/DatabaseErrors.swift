//
//  DatabaseErrors.swift
//  Marker Data
//
//  Created by Milán Várady on 23/11/2023.
//

import Foundation

enum DatabaseValidationError: Error {
    case emptyCredentials
    case nameAlreadyExists
    case illegalName
}

extension DatabaseValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyCredentials:
            "Empty profile credentials"
        case .nameAlreadyExists:
            "A profile with the same name already exists"
        case .illegalName:
            "This name is not allowed"
        }
    }
}

enum NotionValidationError: Error {
    case emptyName
    case emptyWorkspaceName
    case noToken
    case noURL
    case illegalRenameKeyColumn
}

extension NotionValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyName:
            "Empty name field"
        case .emptyWorkspaceName:
            "Empty workspace field"
        case .noToken:
            "No token provided"
        case .noURL:
            "No URL provided"
        case .illegalRenameKeyColumn:
            "'Marker ID' is the default key column and cannot be used in the 'Rename Key Column' field. Please enter a different key column name if you wish to use this field."
        }
    }
}

enum AirtableValidationError: Error {
    case emptyName
    case emptyBaseID
    case illegalRenameKeyColumn
}

extension AirtableValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyName:
            "Empty name field"
        case .emptyBaseID:
            "Empty Base ID field"
        case .illegalRenameKeyColumn:
            "'Marker ID' is the default key column and cannot be used in the 'Rename Key Column' field. Please enter a different key column name if you wish to use this field."
        }
    }
}

enum DatabaseRemoveError: Error {
    case profileDoesntExist
}

enum DatabaseUploadError: Error {
    case failedToUnwrapDBProfile
    case missingJsonFile
    case notionNoToken
    case notionUploadError
    case airtableUploadError
    case csv2notionExecutableNotFound
    case userCancel
}

extension DatabaseUploadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedToUnwrapDBProfile:
            "Failed to get notion credentials"
        case .missingJsonFile:
            "No markers found. Check roles (General->Roles)."
        case .notionNoToken:
            "Missing notion API token"
        case .notionUploadError:
            "Failed to upload to Notion"
        case .airtableUploadError:
            "Failed to upload to Airtable"
        case .csv2notionExecutableNotFound:
            "CSV2Notion executable not found"
        case .userCancel:
            "User initiated cancel"
        }
    }
}

enum DatabaseProfileDuplicationError: Error {
    case noProfileFound
    case failedToDeepCopy
}
