//
//  NotionDBModel.swift
//  Marker Data
//
//  Created by Milán Várady on 05/02/2024.
//

import Foundation
import MarkersExtractor

final class NotionDBModel: DatabaseProfileModel {
    @Published var workspaceName: String
    @Published var token: String
    @Published var databaseURL: String
    @Published var renameKeyColumn: String
    @Published var mergeOnlyColumns: [ExportField]

    init() {
        self.workspaceName = ""
        self.token = ""
        self.databaseURL = ""
        self.renameKeyColumn = ""
        self.mergeOnlyColumns = []
        
        super.init(name: "", plaform: .notion)
    }
    
    override func validate() throws {
        if self.name.isEmpty {
            throw NotionValidationError.emptyName
        }
        if self.workspaceName.isEmpty {
            throw NotionValidationError.emptyWorkspaceName
        }
        if self.token.isEmpty {
            throw NotionValidationError.noToken
        }
        if self.renameKeyColumn == "Marker ID" {
            throw NotionValidationError.illegalRenameKeyColumn
        }
    }
    
    // MARK: Encoding & Decoding
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.workspaceName = try container.decode(String.self, forKey: .workspaceName)
        self.token = try container.decode(String.self, forKey: .token)
        self.databaseURL = try container.decode(String.self, forKey: .databaseURL)
        self.renameKeyColumn = try container.decode(String.self, forKey: .renameKeyColumn)
        self.mergeOnlyColumns = try container.decode([ExportField].self, forKey: .mergeOnly)
        
        // Parent's properties
        let name = try container.decode(String.self, forKey: .name)
        let plaform = try container.decode(DatabasePlatform.self, forKey: .platform)
        
        super.init(name: name, plaform: plaform)
    }
    
    enum CodingKeys: CodingKey {
        case name
        case platform
        case workspaceName
        case token
        case databaseURL
        case renameKeyColumn
        case mergeOnly
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Parent's properties
        try container.encode(self.name, forKey: .name)
        try container.encode(self.plaform, forKey: .platform)
        
        try container.encode(self.workspaceName, forKey: .workspaceName)
        try container.encode(self.token, forKey: .token)
        try container.encode(self.databaseURL, forKey: .databaseURL)
        try container.encode(self.renameKeyColumn, forKey: .renameKeyColumn)
        try container.encode(self.mergeOnlyColumns, forKey: .mergeOnly)
    }
    
    override func copy() -> NotionDBModel? {
        return deepCopy(of: self)
    }
}
