//
//  DominantColorAlgorithmExtension.swift
//  ImageColors
//
//  Created by Denis Dmitriev on 19.09.2023.
//

import Foundation
import DominantColors

extension DominantColorAlgorithm {
    var title: String {
        switch self {
        case .areaAverage:
            return "Area average"
        case .iterative:
            return "Iterative"
        case .kMeansClustering:
            return "Means Clustering"
        }
    }
}
