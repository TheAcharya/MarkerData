//
//  LogManager.swift
//  Marker Data
//
//  Created by Milán Várady on 07/01/2024.
//

import Foundation
import OSLog

struct LogManager {
    public static func export() async {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let date = Date.now.addingTimeInterval(-24 * 3600)
            let position = store.position(date: date)
            
            var entries = try store
                .getEntries(at: position)
                .compactMap { $0 as? OSLogEntryLog }
//                .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
                .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
            
            if entries.isEmpty {
                entries.append("No available logs!")
                entries.append("Note: logs are dropped when the app is closed.")
                entries.append("Logs are only recorded from the instance of the application that is currently running.")
            }
            
            let url = URL.logsFolder
                .appendingPathComponent("MarkerDataLog.txt", conformingTo: .plainText)
            
            try entries.joined(separator: "\n").write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}
