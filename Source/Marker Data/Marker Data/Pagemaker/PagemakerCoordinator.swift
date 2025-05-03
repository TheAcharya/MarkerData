//
//  PagemakerCoordinator.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.05.03.
//

import Foundation
import WebKit

@MainActor
class PagemakerCoordinator: ObservableObject {
    private var webView: WKWebView?
    private var keyboardMonitor: Any?

    func setWebView(_ webView: WKWebView) {
        self.webView = webView
    }

    func setupKeyboardMonitoring() {
        // Remove any existing monitor
        cleanupKeyboardMonitoring()

        // Create a new monitor
        keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let webView = self.webView else { return event }

            // Check for CMD+R
            if event.modifierFlags.contains(.command) && event.keyCode == 15 /* R key */ {
                webView.evaluateJavaScript("window.location.reload()")
                return nil // consume the event
            }

            // Check for CMD+O
            if event.modifierFlags.contains(.command) && event.keyCode == 31 /* O key */ {
                webView.evaluateJavaScript("if(typeof webkitFileDialog === 'function') { webkitFileDialog(); }")
                return nil // consume the event
            }

            return event // pass other events through
        }
    }

    func cleanupKeyboardMonitoring() {
        if let monitor = keyboardMonitor {
            NSEvent.removeMonitor(monitor)
            keyboardMonitor = nil
        }
    }
}
