//
//  ColorExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 07/10/2023.
//

import SwiftUI
import AppKit

extension Color {
    /// Init from a hex string. I.e #FFFFFF for white
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        self.init(red: Double(red), green: Double(green), blue: Double(blue))
    }
    
    /// Hex string representation. I.e #FFFFFF for white
    var hex: String {
        let components = self.components()
        let red = Int(components.red * 255.0)
        let green = Int(components.green * 255.0)
        let blue = Int(components.blue * 255.0)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    private func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat) {
        guard let color = NSColor(self).usingColorSpace(.sRGB) else {
            fatalError("Unable to convert SwiftUI Color to NSColor")
        }
        let red = color.redComponent
        let green = color.greenComponent
        let blue = color.blueComponent
        return (red, green, blue)
    }
    
    static let darkPurple = Color(red: 0.5098, green: 0.2352, blue: 0.6274)
}


