//
//  ColorSwatchSettingsModel.swift
//  Marker Data
//
//  Created by Milán Várady on 20/04/2024.
//

import Foundation
@preconcurrency import DominantColors

struct ColorSwatchSettingsModel: Sendable, Codable, Hashable, Equatable {
    var enableSwatch: Bool
    var algorithm: DeltaEFormula
    var accuracy: DominantColorQuality
    var excludeBlack: Bool
    var excludeWhite: Bool
    var excludeGray: Bool

    static func defaults() -> ColorSwatchSettingsModel {
        ColorSwatchSettingsModel(
            enableSwatch: false,
            algorithm: .CIE76, 
            accuracy: .high,
            excludeBlack: false,
            excludeWhite: false, 
            excludeGray: false
        )
    }
}
