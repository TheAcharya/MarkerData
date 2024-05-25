//
//  SettingsVersioningManager.swift
//  Marker Data
//
//  Created by Milán Várady on 21/04/2024.
//

import Foundation
import OSLog

struct SettingsVersioningManager {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsVersioningManager")

    public static func updateAll() async {
        // Update perferences.json
        do {
            try checkAndUpdateConfiguration(at: URL.preferencesJSON)
        } catch {
            Self.logger.error("Failed to update preferences.json version: \(error.localizedDescription)")
        }

        let configurationURLs = walkDirectory(at: URL.configurationsFolder, options: [.skipsHiddenFiles, .skipsPackageDescendants]).filter {
            $0.pathExtension == "json"
        }

        for await configurationURL in configurationURLs {
            do {
                try checkAndUpdateConfiguration(at: configurationURL)
            } catch {
                Self.logger.error("Failed to update \(configurationURL.lastPathComponent) version: \(error.localizedDescription)")
            }
        }
    }

    private static func checkAndUpdateConfiguration(at url: URL) throws {
        // Load JSON as a dict
        var dict = try jsonToDict(from: url)

        // Get version
        guard var version = dict["version"] as? Int else {
            Self.logger.error("Failed get version from: \(url.path(percentEncoded: false))")
            throw VersioningError.failedToGetVersion
        }

        // If older update the dict
        while version < SettingsStore.version {
            Self.logger.notice("Upgrading version of \(url.lastPathComponent) \(version) -> \(version + 1)")

            try upgradeVersion(dict: &dict, version: version)

            dict["version"] = version + 1
            version += 1
        }

        // Save dict to disk
        try dictToJSON(dict: dict, saveTo: url)
    }

    private static func upgradeVersion(dict: inout [String: Any], version: Int) throws {
        switch version {
        case 1:
            // Add color swatch settings
            let colorSwatchDict = try DictionaryEncoder().encode(ColorSwatchSettingsModel.defaults())
            dict["colorSwatchSettings"] = colorSwatchDict
        case 2:
            dict["includeDisabledClips"] = false
        case 3:
            // Add exclude gray option to color swatch settings
            guard var colorSwatchDict: [String: Any] = dict["colorSwatchSettings"] as? [String: Any] else {
                return
            }
            colorSwatchDict["excludeGray"] = false
            dict["colorSwatchSettings"] = colorSwatchDict
        case 4:
            // Add accuracy to color swatch settings
            guard var colorSwatchDict: [String: Any] = dict["colorSwatchSettings"] as? [String: Any] else {
                return
            }
            colorSwatchDict["accuracy"] = ColorSwatchSettingsModel.defaults().accuracy.rawValue
            dict["colorSwatchSettings"] = colorSwatchDict
        case 5:
            // Add useChapterMarkerThumbnails MarkersExtractor parameter
            dict["useChapterMarkerThumbnails"] = SettingsStore.defaults().useChapterMarkerThumbnails
        case 6:
            // Replace `projectTimecode` with `timelineNameAndTimecode`
            if let IDNamingMode = dict["IDNamingMode"] as? String {
                if IDNamingMode == "projectTimecode" {
                    dict["IDNamingMode"] = "timelineNameAndTimecode"
                }
            }
        default:
            throw VersioningError.invalidVersion
        }
    }

    private static func jsonToDict(from url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [String: Any] else {
            throw VersioningError.failedToConvertDataToDict
        }

        return dict
    }

    private static func dictToJSON(dict: [String: Any], saveTo url: URL) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        try jsonData.write(to: url)
    }
}

enum VersioningError: Error {
    case failedToConvertDataToDict
    case failedToGetVersion
    case invalidVersion
}

extension VersioningError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedToConvertDataToDict:
            "Failed to convert data to dict"
        case .failedToGetVersion:
            "Failed to get version"
        case .invalidVersion:
            "Invalid version!"
        }
    }
}
