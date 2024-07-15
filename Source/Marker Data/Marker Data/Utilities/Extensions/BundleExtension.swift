//
//  BundleExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 08/10/2023.
//

import Foundation

extension Bundle {
    var appName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String ??
        ""
    }
    
    var version: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown version"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }

    var safeBundleID: String {
        return Bundle.main.bundleIdentifier ?? "co.theacharya.MarkerData"
    }
}
