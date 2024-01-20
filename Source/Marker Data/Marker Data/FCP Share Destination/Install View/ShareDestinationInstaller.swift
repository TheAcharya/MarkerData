//
//  ShareDestinationInstaller.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import Foundation
import OSLog

struct ShareDestinationInstaller {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ShareDestinationInstaller")
    
    public static func install() async throws {
        Self.logger.notice("Start install Share Destination")
        
        guard let fcpxdestSourceURL = Bundle.main.url(forResource: "Marker Data Source", withExtension: "fcpxdest"),
              let fcpxdestH264 = Bundle.main.url(forResource: "Marker Data H.264", withExtension: "fcpxdest") else {
            
            throw ShareDestinationInstallError.failedToLocateFCPXDEST
        }
        
        for url in [fcpxdestSourceURL, fcpxdestH264] {
            let installScript = """
tell application "Final Cut Pro"
    activate
    open POSIX file "\(url.path(percentEncoded: false))"
end tell
"""
            let script = NSAppleScript(source: installScript)
            var errorInfo: NSDictionary? = nil
            let result = script?.executeAndReturnError(&errorInfo)
            
            if result == nil {
                Self.logger.error("Failed to install Share Destination, error info: \(errorInfo, privacy: .public)")
                throw ShareDestinationInstallError.nilResult
            }
        }
    }
}

enum ShareDestinationInstallError: Error {
    case failedToLocateFCPXDEST
    case nilResult
}
