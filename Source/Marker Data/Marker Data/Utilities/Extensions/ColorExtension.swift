//
//  ColorExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 07/10/2023.
//

import SwiftUI
import AppKit

extension Color: Codable {
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
            // Return black as default
            return (0, 0, 0)
        }

        let red = color.redComponent
        let green = color.greenComponent
        let blue = color.blueComponent
        return (red, green, blue)
    }

    public func isEqual(to color: Color, tolerance: CGFloat = 0.1) -> Bool {
        let (red1, green1, blue1) = components()
        let (red2, green2, blue2) = color.components()

        return abs(red1 - red2) <= tolerance &&
               abs(green1 - green2) <= tolerance &&
               abs(blue1 - blue2) <= tolerance
    }

    static let darkPurple = Color(#colorLiteral(red: 0.2784313725, green: 0.03137254902, blue: 0.5843137255, alpha: 1))

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.hex)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)

        self.init(hex: hex)
    }

    static func == (lhs: Color, rhs: Color) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}


