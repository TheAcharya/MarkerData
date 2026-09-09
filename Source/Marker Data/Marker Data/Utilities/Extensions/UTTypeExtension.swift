//
//  UTTypeExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 07/10/2023.
//
//
//  FCPXML/FCPXMLD UTTypes that resolve without Final Cut Pro installed.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    /// Final Cut Pro XML document (`.fcpxml`).
    public static let fcpxml = Self.finalCutProType(
        identifier: "com.apple.finalcutpro.xml",
        conformingTo: .xml
    )

    /// Final Cut Pro XML bundle (`.fcpxmld`).
    public static let fcpxmld = Self.finalCutProType(
        identifier: "com.apple.finalcutpro.xmld",
        conformingTo: .package
    )

    private static func finalCutProType(identifier: String, conformingTo supertype: UTType) -> UTType {
        UTType(identifier) ?? UTType(importedAs: identifier, conformingTo: supertype)
    }
}
