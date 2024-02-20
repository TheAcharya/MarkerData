//
//  MarkersExtractorModelExtensions.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import Foundation
import MarkersExtractor

extension ExportFolderFormat: Codable, Identifiable {
    var displayName: String {
        switch self {
        case .short:
            "Short"
        case .medium:
            "Medium"
        case .long:
            "Long"
        }
    }

    public var id: String {
        self.rawValue
    }
}

extension MarkerIDMode: Codable, Identifiable {
    var displayName: String {
        switch self {
        case .projectTimecode:
            "Timecode"
        case .name:
            "Name"
        case .notes:
            "Notes"
        }
    }

    public var id: String {
        self.rawValue
    }
}

extension MarkerLabelProperties.AlignHorizontal: Codable, Identifiable {
    var displayName: String {
        switch self {
        case .left:
            "Left"
        case .center:
            "Center"
        case .right:
            "Right"
        }
    }

    public var id: String {
        self.rawValue
    }
}

extension MarkerLabelProperties.AlignVertical: Codable, Identifiable {
    var displayName: String {
        switch self {
        case .top:
            "Top"
        case .center:
            "Center"
        case .bottom:
            "Bottom"
        }
    }

    public var id: String {
        self.rawValue
    }
}

extension ExportField: Codable {}
extension MarkersSource: Codable {}
