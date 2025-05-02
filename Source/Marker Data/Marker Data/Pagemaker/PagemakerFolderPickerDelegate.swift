//
//  PagemakerFolderPickerDelegate.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.02.
//

import Foundation
import WebKit

@MainActor
class PagemakerFolderPickerDelegate: NSObject, WKUIDelegate {
    static let shared = PagemakerFolderPickerDelegate()

    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo) async -> [URL]? {
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
}
