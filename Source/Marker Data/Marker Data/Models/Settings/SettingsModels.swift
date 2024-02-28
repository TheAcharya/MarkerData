//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import Foundation
import MarkersExtractor

enum OverrideImageSizeOption: Int, CaseIterable, Identifiable, Codable {
    case noOverride = 0
    case overrideImageSizePercent
    case overrideImageWidthAndHeight
    
    var id: Int {
        self.rawValue
    }
}

enum ImageMode: Int, CaseIterable, Identifiable, Codable {
    case PNG
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

enum FontNameType: Int, CaseIterable, Identifiable, Codable {
    case arial
    case courierNew
    case helvetica
    case menlo
    case sourceCodePro

    var id: Int {
        self.rawValue
    }

    var displayName : String {
        switch self {
            case .menlo:
                return "Menlo"
            case .arial:
                return "Arial"
            case .helvetica:
                return "Helvetica"
            case .sourceCodePro:
                return "Source Code Pro"
            case .courierNew:
                return "Courier New"
        }
    }

    var markersExtractor: String {
        switch self {
            case .menlo:
                return "Menlo-Regular"
            case .arial:
                return "Arial"
            case .helvetica:
                return "Helvetica"
            case .sourceCodePro:
                return "Source Code Pro"
            case .courierNew:
                return "Courier New"
        }
    }

}

enum FontStyleType: Int, CaseIterable, Identifiable, Codable {
    case regular
    case italic
    case bold

    var id: Int {
        self.rawValue
    }

    var displayName : String {
        switch self {
            case .regular:
                return "Regular"
            case .italic:
                return "Italic"
            case .bold:
                return "Bold"
        }
    }
    
    var markersExtractor: String {
        switch (self) {
                
            case .regular:
                return "Regular"
            case .italic:
                return "Italic"
            case .bold:
                return "Bold"
        }
    }
}
