//
//  DatabaseProfileModel.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import Foundation

struct DatabaseProfileModel: Codable, Equatable, Identifiable {
    let name: String
    let plaform: DatabasePlatform
    
    // Stores api keys, tokens, etc.
    let notionCredentials: NotionCredentials?
    let airtableCredentials: AirtableCredentials?
    
    static func == (lhs: DatabaseProfileModel, rhs: DatabaseProfileModel) -> Bool {
        lhs.name == rhs.name
    }
    
    var id: String {
        name
    }
    
    /// Returns a copy ``DatabaseProfileModel`` object with "copy" added to its name
    func copy() -> DatabaseProfileModel {
        return DatabaseProfileModel(
            name: self.name + " copy",
            plaform: self.plaform,
            notionCredentials: self.notionCredentials,
            airtableCredentials: self.airtableCredentials
        )
    }
}
