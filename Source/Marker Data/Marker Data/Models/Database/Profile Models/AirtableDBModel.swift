//
//  AirtableDBModel.swift
//  Marker Data
//
//  Created by Milán Várady on 05/02/2024.
//

import Foundation

final class AirtableDBModel: DatabaseProfileModel {
    @Published var apiKey: String
    @Published var baseID: String
    @Published var renameKeyColumn: String
    
    init() {
        self.apiKey = ""
        self.baseID = ""
        self.renameKeyColumn = ""
        
        super.init(name: "", plaform: .airtable)
    }
    
    override func validate() -> Bool {
        if self.name.isEmpty || self.baseID.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    // MARK: Encoding & Decoding
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.apiKey = try container.decode(String.self, forKey: .apiKey)
        self.baseID = try container.decode(String.self, forKey: .baseID)
        self.renameKeyColumn = try container.decode(String.self, forKey: .renameKeyColumn)
        
        // Parent's properties
        let name = try container.decode(String.self, forKey: .name)
        let plaform = try container.decode(DatabasePlatform.self, forKey: .platform)
        
        super.init(name: name, plaform: plaform)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case platform
        case apiKey
        case baseID
        case renameKeyColumn
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Parent's properties
        try container.encode(self.name, forKey: .name)
        try container.encode(self.plaform, forKey: .platform)
        
        try container.encode(self.apiKey, forKey: .apiKey)
        try container.encode(self.baseID, forKey: .baseID)
        try container.encode(self.renameKeyColumn, forKey: .renameKeyColumn)
    }
    
    override func copy() -> AirtableDBModel? {
        return deepCopy(of: self)
    }
}
