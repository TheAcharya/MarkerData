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

        let response = await panel.beginSheetModal(for: NSApp.keyWindow!)

        return response == .OK ? panel.urls : nil
    }

    // Handle JavaScript alert dialogs
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
    ) async {
        let alert = NSAlert()
        alert.messageText = "Alert"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")

        await alert.beginSheetModal(for: NSApp.keyWindow!)
    }

    // Handle JavaScript confirm dialogs
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo
    ) async -> Bool {
        let alert = NSAlert()
        alert.messageText = "Confirm"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        await alert.beginSheetModal(for: NSApp.keyWindow!)
        return true
    }

    // Handle JavaScript prompt dialogs
    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo
    ) async -> String? {
        let alert = NSAlert()
        alert.messageText = "Prompt"
        alert.informativeText = prompt
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.stringValue = defaultText ?? ""
        input.placeholderString = prompt

        alert.accessoryView = input

        let response = await alert.beginSheetModal(for: NSApp.keyWindow!)
        return response == .alertFirstButtonReturn ? input.stringValue : nil
    }
}
