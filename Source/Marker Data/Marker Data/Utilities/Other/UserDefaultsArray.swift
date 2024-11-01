//
//  UserDefaultsArray.swift
//  Marker Data
//
//  Created by Milán Várady on 2024.11.01.
//

import Foundation

@propertyWrapper
struct UserDefaultsArray<T: Codable> {
    private let key: String
    private let defaultValue: [T]

    // Add this initializer specifically for arrays
    init(wrappedValue defaultValue: [T], _ key: String) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: [T] {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
            return (try? JSONDecoder().decode([T].self, from: data)) ?? defaultValue
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}
