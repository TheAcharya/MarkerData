//
//  DeminiaturizeAllWindows.swift
//  Marker Data
//
//  Created by Milán Várady on 29/05/2024.
//

import Foundation
import AppKit

func deminiaturizeAllWindows() {
    for window in NSApplication.shared.windows {
        if window.title == "Colors" {
            return
        }
        
        window.deminiaturize(nil)
    }
}
