//
//  SettingsModel.swift
//  Marker Data
//
//  Created by Theo S on 14/04/2023.
//

import Foundation
import MarkersExtractor

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
    
    var markersExtractor: ExportProfileFormat {
        switch self {
            case .Notion:
                return ExportProfileFormat.notion
            case .Airtable:
                return ExportProfileFormat.airtable
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
    
    var markersExtractor: MarkerRoleType? {
        switch self {
            case .None:
                return nil
            case .Video:
                return MarkerRoleType.video
            case .Audio:
                return MarkerRoleType.audio
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
    
    var markersExtractor: MarkerIDMode {
        switch self {
            case .Timecode:
                return MarkerIDMode.projectTimecode
            case .Name:
                return MarkerIDMode.name
            case .Notes:
                return MarkerIDMode.notes
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
    
    var markersExtractor: MarkerImageFormat {
        switch self {
            case .PNG:
                return .still(.png)
            case .JPG:
                return .still(.jpg)
            case .GIF:
                return .animated(.gif)
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
    
    var markersExtractor: MarkerLabelProperties.AlignHorizontal {
        switch self {
            case .Left:
                return .left
            case .Center:
                return .center
            case .Right:
                return .right
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
    var markersExtractor: MarkerLabelProperties.AlignVertical {
        switch self {
        
            case .Top:
                return .top
            case .Center:
                return .center
            case .Bottom:
                return .bottom
        }
    }
}

