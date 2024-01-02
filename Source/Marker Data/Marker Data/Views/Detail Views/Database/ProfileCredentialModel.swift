//
//  ProfileCredentialModel.swift
//  Marker Data
//
//  Created by Milán Várady on 23/11/2023.
//

import Foundation

struct NotionCredentials: Codable {
    let token: String
    let databaseURL: String?
}

struct AirtableCredentials: Codable {
    let apiKey: String
    let baseID: String
}
