//
//  class AverageColorsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import CoreImage
import DominantColors

struct ColorsExtractorService {
    static func extract(from cgImage: CGImage, method: ColorExtractMethod, count: Int = 8, formula: DeltaEFormula = .CIE76, quality: DominantColorQuality, options: [DominantColors.Options] = []) async throws -> [CGColor] {
        return try await withCheckedThrowingContinuation({ continuation in
            DispatchQueue.global(qos: .utility).async {
                switch method {
                case .averageColor:
                    do {
                        let colors = try DominantColors.kMeansClusteringColors(image: cgImage, count: count)
                        continuation.resume(returning: colors)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                case .averageAreaColor:
                    do {
                        let colors = try DominantColors.averageColors(image: cgImage, count: count)
                        continuation.resume(returning: colors)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                case .dominationColor:
                    do {
                        let colors = try DominantColors.dominantColors(image: cgImage, quality: quality, algorithm: formula, maxCount: count, options: options)
                        continuation.resume(returning: colors)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                }
            }
        })
    }
}
