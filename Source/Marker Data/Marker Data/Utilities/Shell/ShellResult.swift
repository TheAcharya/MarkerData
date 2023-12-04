//
//  ShellResult.swift
//  Marker Data
//
//  Created by Milán Várady on 21/11/2023.
//

import Foundation

/// Returned by functions that run shell commands, ``shell(_:)-6b0df`` and ``ShellOutputStream``
public struct ShellResult {
    let output: String
    let didFail: Bool
}
