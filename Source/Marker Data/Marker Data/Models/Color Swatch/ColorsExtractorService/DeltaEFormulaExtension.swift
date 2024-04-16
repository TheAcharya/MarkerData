//
//  DeltaEFormulaExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import DominantColors

extension DeltaEFormula {
    var name: String {
        switch self {
        case .euclidean:
            return "Euclidean"
        case .CIE76:
            return "CIE76"
        case .CIE94:
            return "CIE94"
        case .CIEDE2000:
            return "CIEDE2000"
        case .CMC:
            return "CMC"
        }
    }
}

extension DeltaEFormula: CustomStringConvertible {
    public var description: String {
        switch self {
        case .euclidean:
            return "Computes the Euclidean distance in RGB color space."
        case .CIE76:
            return "CIE76 algorithm calculates difference in Lab color space."
        case .CIE94:
            return "The CIE94 algorithm is an improvement of CIE76, it calculates the difference in the Lab color space. Slightly slower than CIE76."
        case .CIEDE2000:
            return "The CIEDE2000 algorithm is the most accurate color comparison algorithm in the Lab color space. It is significantly slower than its predecessors."
        case .CMC:
            return "The CMC algorithm calculates the difference in the LHS (Luminance, Chroma, Hue) color space."
        }
    }
}

