//
//  MainViews.swift
//  Marker Data
//
//  Created by Milán Várady on 05/11/2023.
//

import Foundation

/// Views selectable in the sidebar
enum MainViews: String, CaseIterable, Identifiable {
    case extract
    case general
    case image
    case label
    case configurations
    case databases
    case about

    var id: String {
        self.rawValue
    }
}
