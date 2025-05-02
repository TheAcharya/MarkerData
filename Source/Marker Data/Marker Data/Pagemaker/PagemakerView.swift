//
//  PagemakerView.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.02.
//

import SwiftUI
import WebViewKit

struct PagemakerView: View {
    @StateObject private var webViewState = WebViewStateManager()

    var body: some View {
        ZStack {
            // Main WebView
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

                    // Set navigation delegate to handle both loading state and external links
                    webView.navigationDelegate = webViewState
                }
            )

            // Loading overlay
            if webViewState.isLoading {
                loadingView
            }
        }
    }

    // Custom loading view
    private var loadingView: some View {
        ZStack {
            Color(.windowBackgroundColor)
                .opacity(0.7)

            VStack(spacing: 20) {
                ProgressView()
                    .controlSize(.large)
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))

                Text("Loading...")
                    .font(.headline)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.regular)
                    .shadow(radius: 10)
            )
        }
        .transition(.opacity)
        .animation(.easeInOut, value: webViewState.isLoading)
    }
}
