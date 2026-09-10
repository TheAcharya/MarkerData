//
//  PagemakerUIDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.03.
//

import Foundation
import WebKit

@MainActor
class PagemakerUIDelegate: NSObject, WKUIDelegate {
    static let shared = PagemakerUIDelegate()

    // Folder picker functionality
    func webView(
        _ webView: WKWebView,
        runOpenPanelWith parameters: WKOpenPanelParameters,
        initiatedByFrame frame: WKFrameInfo
    ) async -> [URL]? {
        return try? await selectFolders(parameters: parameters)
    }

    private func selectFolders(parameters: WKOpenPanelParameters) async throws -> [URL]? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.message = "Select a folder extracted from Marker Data"
        panel.prompt = "Select Folder"

        let response: NSApplication.ModalResponse = if let window = NSApp.keyWindow {
            await panel.beginSheetModal(for: window)
        } else {
            await panel.begin()
        }

        return response == .OK ? panel.urls : nil
    }

    // Handle JavaScript alert dialogs
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
    ) async {
        let alert = makeAlert(message: message)
        alert.addButton(withTitle: "OK")

        await present(alert)
    }

    // Handle JavaScript confirm dialogs
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
        let alert = makeAlert(message: message)
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        return await present(alert) == .alertFirstButtonReturn
    }

    // Handle JavaScript prompt dialogs
    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
        let alert = makeAlert(message: prompt)
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.stringValue = defaultText ?? ""
        input.placeholderString = prompt

        alert.accessoryView = input

        let response = await present(alert)
        return response == .alertFirstButtonReturn ? input.stringValue : nil
    }

    /// Matches the app's SwiftUI dialogs: Icon Composer app icon, the JavaScript
    /// message as the title, and any paragraph after a blank line as detail.
    private func makeAlert(message: String) -> NSAlert {
        let paragraphs = message
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n\n")

        let alert = NSAlert()
        alert.icon = MarkerDataAppIcon.alertImage
        // NSAlert defaults to .warning; the app's SwiftUI dialogs are informational.
        alert.alertStyle = .informational
        alert.messageText = paragraphs.first.flatMap { $0.isEmpty ? nil : $0 } ?? Bundle.main.appName
        alert.informativeText = paragraphs.dropFirst().joined(separator: "\n\n")

        return alert
    }

    /// Falls back to app-modal when no window is key (background app, open menu).
    @discardableResult
    private func present(_ alert: NSAlert) async -> NSApplication.ModalResponse {
        guard let window = NSApp.keyWindow else {
            return alert.runModal()
        }

        return await alert.beginSheetModal(for: window)
    }
}
