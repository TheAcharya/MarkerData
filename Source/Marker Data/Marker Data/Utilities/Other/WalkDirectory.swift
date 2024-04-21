//
//  WalkDirectory.swift
//  Marker Data
//
//  Created by Milán Várady on 21/04/2024.
//

import Foundation

@Sendable
func walkDirectory(at url: URL, options: FileManager.DirectoryEnumerationOptions) -> AsyncStream<URL> {
    AsyncStream { continuation in
        Task {
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: options)

            while let fileURL = enumerator?.nextObject() as? URL {
                continuation.yield(fileURL)
            }

            continuation.finish()
        }
    }
}
