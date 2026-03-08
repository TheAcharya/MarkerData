//
//  WindowSize.swift
//  Marker Data
//
//  Created by Milán Várady on 05/11/2023.
//

import Foundation

struct WindowSize {
    static let fullWidth: CGFloat = 920
    static let fullHeight: CGFloat = 500
    static let sidebarWidth: CGFloat = 208
    static var detailWidth: CGFloat { Self.fullWidth - Self.sidebarWidth }
}
