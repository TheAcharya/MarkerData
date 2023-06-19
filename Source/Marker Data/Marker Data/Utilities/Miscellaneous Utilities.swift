import Foundation
import AppKit

extension NSColor {
    
    convenience init(
        rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat),
        alpha: CGFloat
    ) {
        self.init(red: rgbComponents.red, green: rgbComponents.green, blue: rgbComponents.blue, alpha: alpha)
    }

    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        (red: self.redComponent, green: self.greenComponent, blue: self.blueComponent)
    }

    func withNewAlpha(_ alphaValue: CGFloat) -> NSColor {
        NSColor(
            rgbComponents: self.rgbComponents,
            alpha: alphaValue
        )
    }
    
}
