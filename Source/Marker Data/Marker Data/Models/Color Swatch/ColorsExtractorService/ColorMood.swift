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
    var isExcludeWhite: Bool
    var isExcludeBlack: Bool

    var flags: [DominantColors.Flag] {
        var flags = [DominantColors.Flag]()
        if isExcludeBlack {
            flags.append(.excludeBlack)
        }
        if isExcludeWhite {
            flags.append(.excludeWhite)
        }
        return flags
    }

    init(formula: DeltaEFormula, excludeBlack: Bool, excludeWhite: Bool) {
        self.method = .dominationColor
        self.formula = formula
        self.isExcludeBlack = excludeBlack
        self.isExcludeWhite = excludeWhite
    }
}
