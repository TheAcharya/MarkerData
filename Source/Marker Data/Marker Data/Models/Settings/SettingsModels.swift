//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import Foundation
import MarkersExtractor

enum IdNamingMode: Int, CaseIterable, Identifiable {

    case Timecode = 0
    case Name
    case Notes

    var id: Int {
        self.rawValue
    }

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

enum ImageMode: Int, CaseIterable, Identifiable {

    case PNG = 0
    case JPG
    case GIF

    var id: Int {
        self.rawValue
    }

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

enum LabelHorizontalAlignment: Int, CaseIterable, Identifiable {

    case Left = 0
    case Center
    case Right

    var id: Int {
        self.rawValue
    }

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

enum LabelVerticalAlignment: Int, CaseIterable, Identifiable {

    case Top = 0
    case Center
    case Bottom

    var id: Int {
        self.rawValue
    }

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

enum FontNameType: Int, CaseIterable, Identifiable {
    
    case Arial = 0
    case CourierNew
    case Helvetica
    case Menlo
    case SourceCodePro

    var id: Int {
        self.rawValue
    }

    var displayName : String {
        switch self {
            case .Menlo:
                return "Menlo"
            case .Arial:
                return "Arial"
            case .Helvetica:
                return "Helvetica"
            case .SourceCodePro:
                return "Source Code Pro"
            case .CourierNew:
                return "Courier New"
        }
    }

    var markersExtractor: String {
        switch self {
            case .Menlo:
                return "Menlo-Regular"
            case .Arial:
                return "Arial"
            case .Helvetica:
                return "Helvetica"
            case .SourceCodePro:
                return "Source Code Pro"
            case .CourierNew:
                return "Courier New"
        }
    }

}

enum FontStyleType: Int, CaseIterable, Identifiable {

    case Regular = 0
    case Italic
    case Bold

    var id: Int {
        self.rawValue
    }

    var displayName : String {
        switch self {
            case .Regular:
                return "Regular"
            case .Italic:
                return "Italic"
            case .Bold:
                return  "Bold"
        }
    }
    
    var markersExtractor: String {
        switch (self) {
                
            case .Regular:
                return "Regular"
            case .Italic:
                return "Italic"
            case .Bold:
                return "Bold"
        }
    }
}


enum UserFolderFormat: Int, CaseIterable, Identifiable {

    case Short
    case Medium
    case Long

    var id: Int {
        self.rawValue
    }

    var displayName : String  {
        switch (self) {
            case .Short:
                return "Short"
            case .Medium:
                return "Medium"
            case .Long:
                return "Long"
        }
    }

    var markersExtractor: ExportFolderFormat {
        switch (self) {
            case .Short:
                return .short
            case .Medium:
                return .medium
            case .Long:
                return .long
        }
    }
}

struct OverlayItem: Identifiable, Equatable {
    let overlay: ExportField
    
    var name: String {
        overlay.name
    }
    
    var isSelected: Bool
    
    mutating func flipSelection(settings: SettingsContainer) {
        settings.store.flipOverlayState(overlay: self.overlay)
        self.isSelected = !self.isSelected
    }
    
    mutating func removeSelection() {
        self.isSelected = false
    }
    
    var id: ExportField {
        self.overlay
    }
}