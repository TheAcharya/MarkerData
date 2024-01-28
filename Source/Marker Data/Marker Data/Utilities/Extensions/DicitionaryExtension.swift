//
//  DicitionaryExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import Foundation

// This is used to compare configurations

protocol CustomEquatable {
    func isEqualTo(_ other: Any?) -> Bool
}

extension Dictionary where Key == String, Value == Any {
    func isEqualTo(_ other: [String: Any]) -> Bool {
        for (key, value1) in self {
            if let value2 = other[key] {
                if let v1 = value1 as? CustomEquatable, let v2 = value2 as? CustomEquatable {
                    if !v1.isEqualTo(v2) {
                        return false
                    }
                } else if let v1 = value1 as? [String: Any], let v2 = value2 as? [String: Any] {
                    if !v1.isEqualTo(v2) {
                        return false
                    }
                } else if String(describing: value1) != String(describing: value2) {
                    return false
                }
            }
        }
        return true
    }
}
