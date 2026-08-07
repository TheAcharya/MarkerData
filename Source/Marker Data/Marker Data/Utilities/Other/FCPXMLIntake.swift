//
//  FCPXMLIntake.swift
//  Marker Data
//
//  Created by Vigneswaran Rajkumar
//
//
//  Resolves FCPXML from files, Finder text clippings, and Final Cut Pro pasteboard drops.
//

import Foundation
import OSLog
import UniformTypeIdentifiers

enum FCPXMLIntake {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FCPXMLIntake")

    /// `NSItemProvider` is not `Sendable`; wrap for async load callbacks (same pattern as Roles drop).
    private struct UncheckedItemProvider: @unchecked Sendable {
        let provider: NSItemProvider
    }

    @MainActor
    static func resolve(_ url: URL) async throws -> URL? {
        if url.conformsToType([.fcpxml]) {
            return url
        }

        if url.conformsToType([.fcpxmld]) {
            return url
        }

        if TextClippingReader.isTextClipping(url),
           let data = try TextClippingReader.fcpxmlData(from: url) {
            logger.info("Resolved FCPXML from text clipping: \(url.lastPathComponent, privacy: .public)")
            return try writeTemporaryFCPXML(data, suggestedName: url.deletingPathExtension().lastPathComponent)
        }

        return nil
    }

    /// Resolves FCPXML URLs from drop providers (FCP timeline pasteboard, file URLs, or text clippings).
    /// Supports multiple Finder file drops; FCP pasteboard typically yields one timeline.
    @MainActor
    static func urls(from providers: [NSItemProvider]) async -> [URL] {
        var results: [URL] = []

        for provider in providers {
            let boxed = UncheckedItemProvider(provider: provider)

            if provider.hasRepresentationConforming(toTypeIdentifier: UTType.fcpxml.identifier),
               let data = await loadDataRepresentation(from: boxed, type: .fcpxml),
               let url = try? writeTemporaryFCPXML(data, suggestedName: "FCP Drop") {
                logger.info("Received FCPXML pasteboard drop (\(data.count) bytes)")
                results.append(url)
                continue
            }

            if provider.canLoadObject(ofClass: URL.self),
               let url = await loadFileURL(from: boxed),
               let resolved = try? await resolve(url) {
                results.append(resolved)
            }
        }

        return results
    }

    static func writeTemporaryFCPXML(_ data: Data, suggestedName: String) throws -> URL {
        try FileManager.default.createDirectory(at: .FCPExportCacheFolder, withIntermediateDirectories: true)

        let baseName = sanitizedFileName(from: suggestedName)
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        var fileURL = URL.FCPExportCacheFolder
            .appendingPathComponent("\(baseName)-\(timestamp)", conformingTo: .fcpxml)

        var counter = 2
        while FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            fileURL = URL.FCPExportCacheFolder
                .appendingPathComponent("\(baseName)-\(timestamp)-\(counter)", conformingTo: .fcpxml)
            counter += 1
        }

        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    private static func loadDataRepresentation(from boxed: UncheckedItemProvider, type: UTType) async -> Data? {
        await withCheckedContinuation { continuation in
            _ = boxed.provider.loadDataRepresentation(for: type) { data, _ in
                continuation.resume(returning: data)
            }
        }
    }

    private static func loadFileURL(from boxed: UncheckedItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            _ = boxed.provider.loadObject(ofClass: URL.self) { url, _ in
                continuation.resume(returning: url)
            }
        }
    }

    private static func sanitizedFileName(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let invalidCharacters = CharacterSet(charactersIn: "/\\:?*\"<>|")
        let cleaned = trimmed
            .components(separatedBy: invalidCharacters)
            .joined(separator: "-")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.isEmpty || cleaned.hasPrefix("<?xml") {
            return "FCP Drop"
        }

        return String(cleaned.prefix(80))
    }
}
