//
//  AirtableDBModel.swift
//  Marker Data
//
//  Created by Milán Várady on 05/02/2024.
//

import Foundation

final class AirtableDBModel: DatabaseProfileModel {
    @Published var token: String
    @Published var baseID: String
    @Published var tableID: String
    @Published var renameKeyColumn: String
    
    init() {
        self.token = ""
        self.baseID = ""
        self.tableID = ""
        self.renameKeyColumn = ""
        
        super.init(name: "", plaform: .airtable)
    }
    
    override func validate() throws {
        if self.name.isEmpty {
            throw AirtableValidationError.emptyName
        }
        if self.baseID.isEmpty {
            throw AirtableValidationError.emptyBaseID
        }
        if self.renameKeyColumn == "Marker ID" {
            throw NotionValidationError.illegalRenameKeyColumn
        }
    }
    
    // MARK: Encoding & Decoding
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.token = try container.decode(String.self, forKey: .token)
        self.baseID = try container.decode(String.self, forKey: .baseID)
        self.tableID = try container.decode(String.self, forKey: .tableID)
        self.renameKeyColumn = try container.decode(String.self, forKey: .renameKeyColumn)
        
        // Parent's properties
        let name = try container.decode(String.self, forKey: .name)
        let plaform = try container.decode(DatabasePlatform.self, forKey: .platform)
        
        super.init(name: name, plaform: plaform)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case platform
        case token
        case baseID
        case tableID
        case renameKeyColumn
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Parent's properties
        try container.encode(self.name, forKey: .name)
        try container.encode(self.plaform, forKey: .platform)
        
        try container.encode(self.token, forKey: .token)
        try container.encode(self.baseID, forKey: .baseID)
        try container.encode(self.tableID, forKey: .tableID)
        try container.encode(self.renameKeyColumn, forKey: .renameKeyColumn)
    }
    
    override func copy() -> AirtableDBModel? {
        return deepCopy(of: self)
    }
}
