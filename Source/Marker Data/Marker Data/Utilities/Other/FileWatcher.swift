//
//  FileWatcher.swift
//  Marker Data
//
//  Created by Milán Várady on 2026. 03. 07..
//

import Foundation

actor FileWatcher {
    private var source: DispatchSourceFileSystemObject?
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func startWatching(onChange: @escaping @Sendable () -> Void) throws {
        let fd = open(url.path(percentEncoded: false), O_EVTONLY)
        guard fd >= 0 else {
            throw CocoaError(.fileNoSuchFile)
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: .write,          // .write fires when contents change
            queue: DispatchQueue.global()
        )

        source.setEventHandler {
            onChange()
        }

        source.setCancelHandler {
            close(fd)
        }

        source.resume()
        self.source = source
    }

    func stopWatching() {
        source?.cancel()
        source = nil
    }
}
