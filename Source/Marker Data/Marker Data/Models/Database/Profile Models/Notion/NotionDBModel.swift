//
//  NotionDBModel.swift
//  Marker Data
//
//  Created by Milán Várady on 05/02/2024.
//

import Foundation

final class NotionDBModel: DatabaseProfileModel {
    @Published var workspaceName: String
    @Published var token: String
    @Published var databaseURL: String
    @Published var renameKeyColumn: String
    @Published var mergeOnlyColumns: [NotionMergeOnlyColumn]
    
    init() {
        self.workspaceName = ""
        self.token = ""
        self.databaseURL = ""
        self.renameKeyColumn = ""
        self.mergeOnlyColumns = []
        
        super.init(name: "", plaform: .notion)
    }
    
    override func validate() -> Bool {
        if self.name.isEmpty || self.workspaceName.isEmpty || self.token.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    // MARK: Encoding & Decoding
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.workspaceName = try container.decode(String.self, forKey: .workspaceName)
        self.token = try container.decode(String.self, forKey: .token)
        self.databaseURL = try container.decode(String.self, forKey: .databaseURL)
        self.renameKeyColumn = try container.decode(String.self, forKey: .renameKeyColumn)
        self.mergeOnlyColumns = try container.decode([NotionMergeOnlyColumn].self, forKey: .mergeOnly)
        
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

enum NotionMergeOnlyColumn: String, Codable, CaseIterable, Identifiable, Equatable {
    case markerID = "Marker ID"
    case markerName = "Marker Name"
    case markerType = "Marker Type"
    case checked = "Checked"
    case status = "Status"
    case notes = "Notes"
    case markerPosition = "Marker Position"
    case clipType = "Clip Type"
    case clipName = "Clip Name"
    case clipDuration = "Clip Duration"
    case videoRoleAndSubrole = "Video Role & Subrole"
    case audioRoleAndSubrole = "Audio Role & Subrole"
    case eventName = "Event Name"
    case projectName = "Project Name"
    case libraryName = "Library Name"
    case iconImage = "Icon Image"
    case imageFilename = "Image Filename"
    
    var id: String {
        self.rawValue
    }
}