//
//  WebViewStateManager.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.02.
//

import Foundation
import WebKit

/// State manager to track WebView loading state and handle external links
@MainActor
class WebViewStateManager: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var isLoading = true
    private var loadingTimeout: Task<Void, Never>?
    private var baseURL: URL?

    // Called when page starts loading
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true

        // Store the base URL for the first load
        if baseURL == nil {
            baseURL = webView.url
        }

        // Set timeout
        loadingTimeout?.cancel()
        loadingTimeout = Task {
            do {
                try await Task.sleep(for: .seconds(10))
                if !Task.isCancelled {
                    isLoading = false
                }
            } catch {}
        }
    }

    // Called when page finishes loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingTimeout?.cancel()
        isLoading = false
    }

    // Called when page fails to load
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingTimeout?.cancel()
        isLoading = false
    }

    // Called when initial loading fails
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingTimeout?.cancel()
        isLoading = false
    }

    // Handle decision for navigation actions - this is where we intercept external links
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else {
            return .allow
        }

        // Check if this is our PDF export (handled separately)
        if url.pathExtension.lowercased() == "pdf" {
            return .cancel
        }

        // If it's a local file URL within our app bundle or the same as our base URL, allow it
        if url.isFileURL,
            url.absoluteString.contains(Bundle.main.bundleURL.absoluteString) ||
            url.absoluteString == baseURL?.absoluteString {
            return .allow
        }

        // For external links: if it's a link click or form submission
        if navigationAction.navigationType == .linkActivated ||
            navigationAction.navigationType == .formSubmitted {

            // Open in default browser
            NSWorkspace.shared.open(url)

            // Cancel the navigation in the WebView
            return .cancel
        }

        // Allow all other navigation
        return .allow
    }
}
