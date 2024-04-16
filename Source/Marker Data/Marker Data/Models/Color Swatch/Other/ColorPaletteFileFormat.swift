//
//  ColorPaletteFileFormat.swift
//  Marker Data
//
//  Created by Milán Várady on 08/04/2024.
//

import Foundation

enum ColorPaletteFileFormat: String, CaseIterable, Identifiable {
    case png, jpeg, tiff

    var fileExtension: String {
        switch self {
        case .png:
            "png"
        case .jpeg:
            "jpeg"
        case .tiff:
            "tiff"
        }
    }

    var pixelFormat: String {
        switch self {
        case .png:
            "yuvj420p"
        case .jpeg:
            "yuvj420p"
        case .tiff:
            "rgba"
        }
    }

    var id: String { self.rawValue }
}
