//
//  ShareDestinationInstaller.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import Foundation

struct ShareDestinationInstaller {
    public static func install() async throws {
        guard let fcpxdestURL = Bundle.main.url(forResource: "MarkerData", withExtension: "fcpxdest") else {
            throw ShareDestinationInstallError.failedToLocateFCPXDEST
        }
        
        let installScript = """
tell application "Final Cut Pro"
    activate
    open POSIX file "\(fcpxdestURL.path(percentEncoded: false))"
end tell
"""
        
        let script = NSAppleScript(source: installScript)
        var errorInfo: NSDictionary? = nil
        let result = script?.executeAndReturnError(&errorInfo)
        
        if result == nil {
            throw ShareDestinationInstallError.nilResult
        }
    }
}

enum ShareDestinationInstallError: Error {
    case failedToLocateFCPXDEST
    case nilResult
}
