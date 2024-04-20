//
//  ColorMood.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import DominantColors

/// Предустановка цветового отделения по различным сценариям
enum ColorExtractMethod: Int, CaseIterable {
    case averageColor
    case averageAreaColor
    case dominationColor

    var name: String {
        switch self {
        case .averageColor:
            return "Average Color"
        case .averageAreaColor:
            return "Area average color"
        case .dominationColor:
            return "Domination colors"
        }
    }
}

extension ColorExtractMethod: CustomStringConvertible {
    var description: String {
        switch self {
        case .averageColor:
            return "Finds the dominant colors of an image by using using a k-means clustering algorithm."
        case .averageAreaColor:
            return "Finds the dominant colors of an image by using using a area average algorithm."
        case .dominationColor:
            return "Finds the dominant colors of an image by iterating, grouping and sorting its pixels and using the difference between the colors."
        }
    }
}

extension ColorExtractMethod: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}
