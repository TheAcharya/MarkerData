//
//  OptionalKeyboardShortcut.swift
//  Marker Data
//
//  Created by Milán Várady on 2026. 03. 10..
//

import SwiftUI

extension View {
    func optionalKeyboardShortcut(_ shortcut: KeyboardShortcut?) -> some View {
        // We handle the 'nil' internally.
        // If it's nil, we just return 'self' without a branch.
        Group {
            if let shortcut = shortcut {
                self.keyboardShortcut(shortcut)
            } else {
                self
            }
        }
    }
}
