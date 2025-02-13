//
//  StringExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 2025.02.13.
//

import Foundation

extension String {
    func cleanTerminalOutput() -> String {
        // Regex to match ANSI escape codes
        let ansiEscapePattern = "\\u001B\\[[0-9;]*[a-zA-Z]"
        // Match backspaces with preceding characters
        let backspacePattern = ".\\u{08}"
        // Regex for other unwanted characters
        let unwantedPattern = "[\\r\\f]"

        let cleaned = self
            .replacingOccurrences(of: ansiEscapePattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: backspacePattern, with: "", options: .regularExpression)
            .replacingOccurrences(of: unwantedPattern, with: "", options: .regularExpression)

        return cleaned
    }
}
