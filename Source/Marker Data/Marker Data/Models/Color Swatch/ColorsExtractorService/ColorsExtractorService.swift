//
//  class AverageColorsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import CoreImage
import DominantColors

class ColorsExtractorService {
    
    static func extract(from cgImage: CGImage, method: ColorExtractMethod, count: Int = 8, formula: DeltaEFormula = .CIE76, flags: [DominantColors.Flag] = []) async throws -> [CGColor] {
        return try await withCheckedThrowingContinuation({ continuation in
            DispatchQueue.global(qos: .utility).async {
                switch method {
                case .averageColor:
                    do {
                        let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .kMeansClustering)
                        continuation.resume(returning: colors)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                case .averageAreaColor:
                    do {
                        let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .areaAverage(count: UInt8(count)))
                        continuation.resume(returning: colors)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                case .dominationColor:
                    do {
                        let colors = try DominantColors.dominantColors(image: cgImage, algorithm: .iterative(formula: formula), dominationColors: count, flags: flags)
                        continuation.resume(returning: colors)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                }
            }
        })
    }
}
