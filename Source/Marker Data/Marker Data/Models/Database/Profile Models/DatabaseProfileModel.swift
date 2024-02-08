//
//  DatabaseProfileModel.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import Foundation

/// A parent class for Notion and Airtable datbase models
class DatabaseProfileModel: ObservableObject, Equatable, Identifiable, Codable {
    var name: String
    let plaform: DatabasePlatform
    
    init(name: String, plaform: DatabasePlatform) {
        self.name = name
        self.plaform = plaform
    }
    
    static func == (lhs: DatabaseProfileModel, rhs: DatabaseProfileModel) -> Bool {
        lhs.name == rhs.name
    }
    
    var id: String {
        name
    }
    
    func getJSONURL() -> URL {
        switch self.plaform {
        case .notion:
            return URL.notionProfilesFolder
                .appendingPathComponent(name, conformingTo: .json)
        case .airtable:
            return URL.airtableProfilesFolder
                .appendingPathComponent(name, conformingTo: .json)
        }
    }
    
    func validate() -> Bool {
        return !name.isEmpty
    }
    
    func copy() -> DatabaseProfileModel? {
        return deepCopy(of: self)
    }
}
