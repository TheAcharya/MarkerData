//
//  WindowSize.swift
//  Marker Data
//
//  Created by Milán Várady on 05/11/2023.
//

import Foundation

struct WindowSize {
    static let fullWidth: CGFloat = 900
    static let fullHeight: CGFloat = 500
    static let sidebarWidth: CGFloat = 200
    static var detailWidth: CGFloat { Self.fullWidth - Self.sidebarWidth }
}
