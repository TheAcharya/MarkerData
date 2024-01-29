//
//  UTTypeExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 07/10/2023.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    public static let fcpxml = UTType("com.apple.finalcutpro.xml")!
    public static let fcpxmld = UTType(tag: "fcpxmld", tagClass: .filenameExtension, conformingTo: nil)!
}
