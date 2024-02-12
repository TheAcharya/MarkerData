//
//  DeepCopy.swift
//  Marker Data
//
//  Created by Milán Várady on 06/02/2024.
//

import Foundation

func deepCopy<T: Codable>(of object: T) -> T? {
    do {
        let json = try JSONEncoder().encode(object)
        return try JSONDecoder().decode(T.self, from: json)
    } catch let error {
        print(error.localizedDescription)
        return nil
    }
}
