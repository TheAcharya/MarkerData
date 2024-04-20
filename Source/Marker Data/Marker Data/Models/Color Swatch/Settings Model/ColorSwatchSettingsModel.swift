//
//  ColorSwatchSettingsModel.swift
//  Marker Data
//
//  Created by Milán Várady on 20/04/2024.
//

import Foundation
import DominantColors

struct ColorSwatchSettingsModel: Codable, Hashable, Equatable {
    var enableSwatch: Bool
    var algorithm: DeltaEFormula
    var excludeBlack: Bool
    var excludeWhite: Bool

    static func defaults() -> ColorSwatchSettingsModel {
        ColorSwatchSettingsModel(
            enableSwatch: false,
            algorithm: .CIE76,
            excludeBlack: false,
            excludeWhite: false
        )
    }
}
