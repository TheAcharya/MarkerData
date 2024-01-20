//
//  ProfileCredentialModel.swift
//  Marker Data
//
//  Created by Milán Várady on 23/11/2023.
//

import Foundation

struct NotionCredentials: Codable {
    let workspaceName: String
    let token: String
    let databaseURL: String?
    let renameKeyColumn: String?
}

struct AirtableCredentials: Codable {
    let apiKey: String
    let baseID: String
    let renameKeyColumn: String?
}
