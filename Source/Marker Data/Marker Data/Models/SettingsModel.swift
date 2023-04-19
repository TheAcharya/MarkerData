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

enum IdNamingMode: Int, CaseIterable {
    case Timecode = 0
    case Name
    case Notes
    
    var displayName : String {
        switch self {
            case .Timecode:
                return "Timecode"
            case .Name:
                return "Name"
            case .Notes:
                return "Notes"
        }
    }
}

enum ImageMode: Int, CaseIterable {
    case PNG = 0
    case JPG
    case GIF
    
    var displayName : String {
        switch self {
            case .PNG:
                return "PNG"
            case .JPG:
                return "JPG"
            case .GIF:
                return "GIF"
        }
    }
}

enum LabelHorizontalAlignment: Int, CaseIterable {
    case Left = 0
    case Center
    case Right
    
    var displayName : String {
        switch self {
            case .Left:
                return "Left"
            case .Center:
                return "Center"
            case .Right:
                return "Right"
        }
    }
}

enum LabelVerticalAlignment: Int, CaseIterable {
    case Top = 0
    case Center
    case Bottom
    
    var displayName : String {
        switch self {
            case .Top:
                return "Top"
            case .Center:
                return "Center"
            case .Bottom:
                return "Bottom"
        }
    }
}

