//
//  ColorPaletteRenderer.swift
//  Marker Data
//
//  Created by Milán Várady on 20/04/2024.
//

import Foundation
import MarkersExtractor
import OSLog

/// Provides method for color palette generation
///
/// After the marker extraction is done, the render method of this object is called,
/// which creates new images with the dominant colors of the images merged onto them.
/// If the image format is GIF, the palette is saved separately and the export JSON is also updated.
struct ColorPaletteRenderer {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ColorPaletteRenderer")

    /// Renders color palettes into export images.
    /// - Returns: `true` if swatch work ran; `false` if skipped (no images, unsupported GIF, etc.).
    @discardableResult
    static func render(exportResult: ExportResult, swatchSettings: ColorSwatchSettingsModel, progress: ProgressViewModel) async -> Bool {
        guard let imageFileURLs = try? FileManager.default
            .contentsOfDirectory(at: exportResult.exportFolder, includingPropertiesForKeys: [])
            .filter({ ["png", "jpg", "jpeg", "gif"].contains($0.pathExtension.lowercased()) }) // Filter for images
            .filter({ !$0.lastPathComponent.contains("icon-marker") }) // Filter out marker icons
        else {
            Self.logger.error("Failed to get contents of directory")
            return false
        }

        // No stills (no-media / skip image generation / empty export)
        guard !imageFileURLs.isEmpty else {
            Self.logger.notice("No images found for color palette. Skipping swatch render.")
            return false
        }

        let isGIF: Bool = imageFileURLs.contains(where: { $0.pathExtension == "gif" })
        let isJSON = exportResult.jsonManifestPath != nil

        // Skip palette if image format is GIF and the export format is not JSON
        if isGIF && !isJSON {
            Self.logger.warning("GIF export can be only used with JSON. Skipping palette creation.")
            return false
        }

        // Only retitle the progress bar when there is real swatch work to do
        progress.applyTaskAppearance(
            taskDescription: "Analysing swatch",
            taskIcon: "swatchpalette"
        )

        let imageService = ImageRenderService()
        let colorMood = ColorMood(
            formula: swatchSettings.algorithm,
            excludeBlack: swatchSettings.excludeBlack,
            excludeWhite: swatchSettings.excludeWhite,
            excludeGray: swatchSettings.excludeGray,
            quality: swatchSettings.accuracy
        )

        let imageStrips: [ImageStrip] = imageFileURLs.map { url in
            let outputURL = if isGIF {
                Self.getSeparatePaletteURL(from: url)
            } else {
                url
            }

            let imageStrip = ImageStrip(url: url, exportDirectory: outputURL, colorMood: colorMood)

            return imageStrip
        }

        await imageService.export(
            imageStrips: imageStrips,
            stripHeight: 96,
            colorsCount: 14,
            paletteStripOnly: isGIF,
            progress: progress
        )

        // Update JSON if exporting separate palette
        if isGIF {
            Self.logger.notice("Updating JSON manifest with palette filenames")

            guard let url = exportResult.jsonManifestPath,
                  let data = try? Data(contentsOf: url),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []),
                  let extractResultDicts = json as? [[String: Any]] else {
                Self.logger.error("Failed to get extract result dict")
                return true
            }

            guard let jsonURL = exportResult.jsonManifestPath else {
                Self.logger.error("Failed to get JSON manifest path for palette creation")
                return true
            }

            var updatedResultDict = extractResultDicts

            for index in updatedResultDict.indices {
                if let imageFilename = extractResultDicts[index]["Image Filename"] as? String {
                    updatedResultDict[index]["Palette Filename"] = Self.getSeparatePaletteName(from: imageFilename)
                }
            }
            Self.updateResultJSON(at: jsonURL, to: updatedResultDict)
        }

        return true
    }

    private static func getSeparatePaletteURL(from url: URL) -> URL {
        return url
            .mutatingLastPathComponent {
                Self.getSeparatePaletteName(from: $0)
            }
    }

    private static func getSeparatePaletteName(from filename: String) -> String {
        return "\(filename.removingSuffix(".gif"))-Palette.jpg"
    }

    // Used when rendering GIFs
    private static func updateResultJSON(at url: URL, to dict: [[String: Any]]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            try jsonData.write(to: url)
        } catch {
            Self.logger.error("Error writing JSON file for palette: \(error)")
        }
    }
}
