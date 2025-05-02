//
//  PagemakerView.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.02.
//

import SwiftUI
import WebViewKit

struct PagemakerView: View {
    var body: some View {
        WebView(
            url: Bundle.main.url(forResource: "Pagemaker", withExtension: "html"),
            viewConfig: { webView in
                // Set UI delegate for folder picking
                webView.uiDelegate = PagemakerFolderPickerDelegate.shared

                // Add message handler for PDF export
                webView.configuration.userContentController.add(
                    PagemakerPDFExportHandler.shared,
                    name: "exportPDF"
                )
            }
        )
    }
}
