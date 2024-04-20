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

    static func render(exportResult: ExportResult, swatchSettings: ColorSwatchSettingsModel) async {
        guard let url = exportResult.jsonManifestPath,
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let extractResultDicts = json as? [[String: Any]] else {
            return
        }

        let imageFilenames: [String] = extractResultDicts.compactMap {
            $0["Image Filename"] as? String
        }

        let isGIF: Bool = imageFilenames.first?.lowercased().hasSuffix("gif") ?? false

        let imageService = ImageRenderService()
        let colorMood = ColorMood(
            formula: swatchSettings.algorithm,
            excludeBlack: swatchSettings.excludeBlack,
            excludeWhite: swatchSettings.excludeWhite
        )

        let imageStrips: [ImageStrip] = imageFilenames.map { imageFilename in
            let imageURL = exportResult.exportFolder.appendingPathComponent(imageFilename, conformingTo: .image)
            let outputFilenme = if isGIF {
                Self.getSeparatePaletteFilename(gifFilename: imageFilename)
            } else {
                imageFilename
            }
            let outputURL = exportResult.exportFolder.appendingPathComponent(outputFilenme, conformingTo: .image)

            let imageStrip = ImageStrip(url: imageURL, exportDirectory: outputURL, colorMood: colorMood)

            return imageStrip
        }

        await imageService.export(imageStrips: imageStrips, stripHeight: 80, colorsCount: 8, paletteStripOnly: isGIF)

        // Update JSON if exporting separate palette
        if isGIF {
            Self.logger.notice("Updating JSON manifest with palette filenames")

            guard let jsonURL = exportResult.jsonManifestPath else {
                Self.logger.error("Failed to get JSON manifest path for palette creation")
                return
            }

            var updatedResultDict = extractResultDicts

            for index in updatedResultDict.indices {
                if let imageFilename = extractResultDicts[index]["Image Filename"] as? String {
                    updatedResultDict[index]["Palette Filename"] = Self.getSeparatePaletteFilename(gifFilename: imageFilename)
                }
            }
            Self.updateResultJSON(at: jsonURL, to: updatedResultDict)
        }
    }

    private static func getSeparatePaletteFilename(gifFilename: String) -> String {
        "\(gifFilename.removingSuffix(".gif"))-Palette.jpg"
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
