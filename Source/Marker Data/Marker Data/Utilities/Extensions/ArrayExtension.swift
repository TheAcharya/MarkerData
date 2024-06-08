//
//  ArrayExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
