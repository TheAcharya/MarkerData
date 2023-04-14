//
//  SettingsModel.swift
//  Marker Data
//
//  Created by Theo S on 14/04/2023.
//

import Foundation

enum ExportFormat: Int, CaseIterable {
    case Notion = 0
    case Airtable
    
    var displayName : String {
        switch self {
            case .Notion:
                return "Notion"
            case .Airtable:
                return "Airtable"
        }
    }
}

enum ExcludedRoles: Int, CaseIterable {
    case None = 0
    case Video
    case Audio
    
    var displayName : String {
        switch self {
           
            case .None:
                return "None"
            case .Video:
                return "Video"
            case .Audio:
                return "Audio"
        }
    }
}
