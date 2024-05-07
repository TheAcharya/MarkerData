//
//  ColorMood.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import Foundation
import DominantColors

struct ColorMood {
    var formula: DeltaEFormula
    var method: ColorExtractMethod
    var quality: DominantColorQuality
    var isExcludeWhite: Bool
    var isExcludeBlack: Bool
    var isExcludeGray: Bool

    var options: [DominantColors.Options] {
        var options = [DominantColors.Options]()
        if isExcludeBlack {
            options.append(.excludeBlack)
        }
        if isExcludeWhite {
            options.append(.excludeWhite)
        }
        if isExcludeGray {
            options.append(.excludeGray)
        }
        return options
    }

    init(formula: DeltaEFormula, excludeBlack: Bool, excludeWhite: Bool, excludeGray: Bool, quality: DominantColorQuality) {
        self.method = .dominationColor
        self.formula = formula
        self.isExcludeBlack = excludeBlack
        self.isExcludeWhite = excludeWhite
        self.isExcludeGray = excludeGray
        self.quality = quality
    }
}
