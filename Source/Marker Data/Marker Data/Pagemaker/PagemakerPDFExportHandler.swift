//
//  PagemakerPDFExportHandler.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.02.
//

import Foundation
import WebKit
import OSLog
import UniformTypeIdentifiers

@MainActor
class PagemakerPDFExportHandler: NSObject, WKScriptMessageHandler {
    static let shared = PagemakerPDFExportHandler()
    static let logger = Logger(subsystem: "\(Bundle.main.bundleIdentifier!).Pagemaker", category: String(describing: PagemakerPDFExportHandler.self))

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "exportPDF",
              let dict = message.body as? [String: Any],
              let pdfDataUri = dict["pdfData"] as? String,
              let filename = dict["filename"] as? String else {
            Self.logger.error("Pagemaker: Invalid message received: \(message)")
            return
        }

        guard let dataRange = pdfDataUri.range(of: ";base64,"),
              let pdfData = Data(base64Encoded: String(pdfDataUri[dataRange.upperBound...])) else {
            Self.logger.error("Pagemaker: Failed to decode PDF data")
            return
        }

        Task {
            await savePDF(pdfData: pdfData, filename: filename)
        }
    }

    private func savePDF(pdfData: Data, filename: String) async {
        // Show save dialog
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.pdf]
        savePanel.nameFieldStringValue = filename

        let response = await savePanel.beginSheetModal(for: NSApp.keyWindow!)

        if response == .OK, let saveURL = savePanel.url {
            do {
                try pdfData.write(to: saveURL)
            } catch {
                Self.logger.error("Pagemaker: Failed to save PDF: \(error.localizedDescription)")
            }
        }
    }
}
