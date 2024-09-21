//
//  MarkersExtractorModelExtensions.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import Foundation
import MarkersExtractor

extension ExportFolderFormat: Codable {
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
}

extension MarkerIDMode: Codable {
    var displayName: String {
        switch self {
        case .timelineNameAndTimecode:
            "Timeline and Timecode"
        case .name:
            "Name"
        case .notes:
            "Notes"
        }
    }
}

extension MarkerLabelProperties.AlignHorizontal: Codable {
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
}

extension MarkerLabelProperties.AlignVertical: Codable {
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
}

extension ExportField: Codable {}

extension MarkersSource: Codable {}
