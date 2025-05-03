//
//  PagemakerView.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.02.
//

import SwiftUI
import WebViewKit
import WebKit

struct PagemakerView: View {
    @StateObject private var webViewState = WebViewStateManager()
    @State private var webViewRef: WKWebView?

    var body: some View {
        ZStack {
            // Main WebView
            WebView(
                url: Bundle.main.url(forResource: "Pagemaker", withExtension: "html"),
                viewConfig: { webView in
                    // Set delegates
                    webView.uiDelegate = PagemakerUIDelegate.shared
                    webView.navigationDelegate = webViewState

                    // Add message handler for PDF export
                    webView.configuration.userContentController.add(
                        PagemakerPDFExportHandler.shared,
                        name: "exportPDF"
                    )

                    webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

                    // Set navigation delegate to handle both loading state and external links
                    webView.navigationDelegate = self.webViewState

                    // Save web view reference in task so we don't interfere with the view update
                    Task { @MainActor in
                        self.webViewRef = webView
                    }
                }
            )
            // Keyboard shortcuts
            .background {
                VStack {
                    Button("") {
                        webViewRef?.evaluateJavaScript("window.location.reload()")
                    }
                    .keyboardShortcut("r", modifiers: .command)

                    Button("") {
                        webViewRef?.evaluateJavaScript("if(typeof webkitFileDialog === 'function') { webkitFileDialog(); }")
                    }
                    .keyboardShortcut("o", modifiers: .command)
                }
                .opacity(0)
            }

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
