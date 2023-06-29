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

extension String {

    func strip() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

/// Parses either an integer or an empty string as `Int?`.
struct EmptyOrIntParseStrategy: ParseStrategy {

    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        // formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()

    func parse(_ value: String) throws -> Int? {

        if value.strip().isEmpty {
            // empty string
            return nil
        }

        let number = Self.formatter.number(from: value)
        let int = number?.intValue
        return int

    }

}

struct EmptyOrIntFormatStyle: ParseableFormatStyle {

    // static let formatter: NumberFormatter = {
    //     let formatter = NumberFormatter()
    //     formatter.allowsFloats = false
    //     return formatter
    // }()

    static var formatter: NumberFormatter {
        EmptyOrIntParseStrategy.formatter
    }

    var parseStrategy: EmptyOrIntParseStrategy {
        EmptyOrIntParseStrategy()
    }

    func format(_ value: Int?) -> String {

        guard let int = value else {
            return ""
        }

        let nsNumber = NSNumber(value: int)
        let string = Self.formatter.string(from: nsNumber)

        return string ?? ""

    }

}

extension FormatStyle where Self == EmptyOrIntFormatStyle {

    static var emptyOrInt: EmptyOrIntFormatStyle {
        EmptyOrIntFormatStyle()
    }

}
