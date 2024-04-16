//
//  ImageService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 31.08.2023.
//

import SwiftUI
import OSLog

class ImageRenderService: ObservableObject {
    
    @Published var error: ImageRenderServiceError?
    @Published var hasError: Bool = false

    // TODO: progress?
//    @ObservedObject var progress: Progress = .init(total: .zero)
    @Published var isRendering: Bool = false
    
    // TODO: Might want to use marker data settings
//    @AppStorage(DefaultsKeys.exportImageStripFormat)
    private var exportImageStripFormat: ColorPaletteFileFormat = .jpeg

//    @AppStorage(DefaultsKeys.exportImageStripCompressionFactor)
    private var exportImageStripCompressionFactor: Double = 0.0

    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ImageRenderService")

    let operationQueue: OperationQueue = {
       let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        return operationQueue
    }()
    
    // MARK: - Functions
    
    func export(imageStrips: [ImageStrip], stripHeight: CGFloat, colorsCount: Int, paletteStripOnly: Bool) {
        // TODO: progress?
//        configureProgress(total: imageStrips.count)
        renderingStatus(is: true)
        imageStrips.forEach { imageStrip in
            addMergeOperation(
                imageStrip: imageStrip,
                stripHeight: stripHeight,
                colorsCount: colorsCount,
                paletteStripOnly: paletteStripOnly
            )
        }
    }
    
    func stop() {
        operationQueue.cancelAllOperations()
        // TODO: progress?
//        progress = .init(total: .zero)
        renderingStatus(is: false)
    }
    
    // MARK: - Private functions
    
    private func renderingStatus(is rendering: Bool) {
        DispatchQueue.main.async {
            self.isRendering = rendering
        }
    }
    
    private func addMergeOperation(imageStrip: ImageStrip, stripHeight: CGFloat, colorsCount: Int, paletteStripOnly: Bool) {
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
        
        mergeOperation.completionBlock = { [weak self] in
            self?.hasResult(result: mergeOperation.result, exportURL: exportURL)
            // TODO: progress?
//            self?.pushProgress()
        }
        
        operationQueue.addOperation(mergeOperation)
    }
    
    private func hasResult(result: Result<Data, Error>?, exportURL: URL) {
        switch result {
        case .success(let data):
            do {
                try save(jpeg: data, to: exportURL)
            } catch let error {
                hasError(error: error)
            }
        case .failure(let error):
            hasError(error: error)
        case .none:
            hasError(error: ImageRenderServiceError.mergeImageWithStrip)
        }
    }
    
    // TODO: progress?
//    private func configureProgress(total: Int) {
//        DispatchQueue.main.async {
//            self.progress.total = total
//        }
//    }
    
    // TODO: progress?
//    private func pushProgress() {
//        DispatchQueue.main.async {
//            self.progress.current += 1
//            if self.progress.current >= self.progress.total {
//                self.renderingStatus(is: false)
//            }
//        }
//    }

    private func writeImage(jpeg data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }

    private func save(jpeg data: Data, to url: URL) throws {
        try writeImage(jpeg: data, to: url)
        url.stopAccessingSecurityScopedResource()
    }
    
    private func hasError(error: Error) {
        guard let error = error as? LocalizedError else { return }
        DispatchQueue.main.async {
            self.error = ImageRenderServiceError.map(
                errorDescription: error.localizedDescription,
                recoverySuggestion: error.recoverySuggestion
            )
            self.hasError = true
        }
    }
}
