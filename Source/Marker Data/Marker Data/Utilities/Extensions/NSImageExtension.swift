//
//  NSImageExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import Foundation
import AppKit

extension NSImage {
    func scalePreservingAspectRatio(targetSize: NSSize) -> NSImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = NSSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let newImage = NSImage(size: scaledImageSize)
        newImage.lockFocus()
        self.draw(
            in: NSRect(origin: .zero, size: scaledImageSize),
            from: NSRect(origin: .zero, size: self.size),
            operation: .copy,
            fraction: 1.0
        )
        newImage.unlockFocus()
        
        return newImage
    }
}
