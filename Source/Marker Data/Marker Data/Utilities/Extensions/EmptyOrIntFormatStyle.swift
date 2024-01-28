import Foundation

/// Parses either an integer or an empty string as `Int?`.
struct EmptyOrIntParseStrategy: ParseStrategy {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return formatter
    }()

    func parse(_ value: String) throws -> Int? {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Empty string
            return nil
        }

        let number = Self.formatter.number(from: value)
        let int = number?.intValue
        return int

    }
}

struct EmptyOrIntFormatStyle: ParseableFormatStyle {
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
