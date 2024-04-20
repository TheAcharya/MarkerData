//
//  ImageService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 31.08.2023.
//

import SwiftUI
import OSLog

class ImageRenderService {
    var error: ImageRenderServiceError?

    private var exportImageStripFormat: ColorPaletteFileFormat = .jpeg

    private var exportImageStripCompressionFactor: Double = 0.0

    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ImageRenderService")

    private var taskGroup: TaskGroup<Void>? = nil

    // MARK: - Functions
    
    func export(imageStrips: [ImageStrip], stripHeight: CGFloat, colorsCount: Int, paletteStripOnly: Bool) async {
        await withTaskGroup(of: Void.self) { group in
            self.taskGroup = group

            imageStrips.forEach { imageStrip in
                group.addTask {
                    await self.addMergeOperation(
                        imageStrip: imageStrip,
                        stripHeight: stripHeight,
                        colorsCount: colorsCount,
                        paletteStripOnly: paletteStripOnly
                    )
                }
            }
        }
    }
    
    func stop() {
        self.taskGroup?.cancelAll()
    }
    
    // MARK: - Private functions

    func addMergeOperation(imageStrip: ImageStrip, stripHeight: CGFloat, colorsCount: Int, paletteStripOnly: Bool) async {
        guard
            let nsImage = imageStrip.nsImage(),
            let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil),
            let exportURL = imageStrip.exportURL
        else {
            Self.logger.error("Failed to load CGImage from ImageStrip at: \(imageStrip.url)")
            return
        }

        let mergeOperation = ImageMergeOperation(
            colors: imageStrip.colors,
            cgImage: cgImage,
            stripHeight: stripHeight,
            paletteStripOnly: paletteStripOnly,
            colorsCount: colorsCount,
            colorMood: imageStrip.colorMood, 
            format: exportImageStripFormat, 
            compressionFactor: Float(exportImageStripCompressionFactor)
        )

        if let jpegData = await mergeOperation.performMerge() {
            do {
                try save(jpeg: jpegData, to: exportURL)
            } catch let error {
                Self.logger.error("Failed to save palette image. Error: \(error)")
            }
        }
    }

   func writeImage(jpeg data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }

    func save(jpeg data: Data, to url: URL) throws {
        try writeImage(jpeg: data, to: url)
        url.stopAccessingSecurityScopedResource()
    }
}
