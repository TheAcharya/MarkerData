//
//  DeltaEFormulaExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import DominantColors

extension DeltaEFormula: Codable {}

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
            return "Euclidean algorithm calculates difference in RGB colour space."
        case .CIE76:
            return "CIE76 algorithm calculates difference in Lab colour space."
        case .CIE94:
            return "CIE94 algorithm is an improvement of CIE76, it calculates the difference in the Lab colour space."
        case .CIEDE2000:
            return "CIEDE2000 algorithm is the most accurate colour comparison algorithm in the Lab colour space."
        case .CMC:
            return "CMC algorithm calculates the difference in the HCL (Hue, Chroma, Luminance) colour space."
        }
    }
}

