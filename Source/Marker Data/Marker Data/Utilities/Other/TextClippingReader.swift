//
//  TextClippingReader.swift
//  Marker Data
//
//  Created by Vigneswaran Rajkumar
//
//
//  Extracts FCPXML plain text from macOS Finder .textClipping files.
//

import Foundation

enum TextClippingReader {
    private static let utiDataKey = "UTI-Data"
    private static let utf8PlainTextKey = "public.utf8-plain-text"

    static func isTextClipping(_ url: URL) -> Bool {
        url.pathExtension.compare("textClipping", options: .caseInsensitive) == .orderedSame
    }

    static func fcpxmlData(from url: URL) throws -> Data? {
        guard isTextClipping(url) else { return nil }

        let plistData = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)

        guard let dictionary = plist as? [String: Any],
              let utiData = dictionary[utiDataKey] as? [String: Any],
              let plainText = utiData[utf8PlainTextKey] as? String,
              Self.looksLikeFCPXML(plainText) else {
            return nil
        }

        return plainText.data(using: .utf8)
    }

    private static func looksLikeFCPXML(_ text: String) -> Bool {
        text.contains("<fcpxml") || text.contains("<!DOCTYPE fcpxml")
    }
}
