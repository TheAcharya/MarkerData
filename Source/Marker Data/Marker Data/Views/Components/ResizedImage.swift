//
//  ResizedImage.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import SwiftUI

/// Image resized to a specific size
struct ResizedImage: View {
    let resourceName: String
    let width: Int
    let height: Int
    
    init(_ resourceName: String, width: Int, height: Int) {
        self.resourceName = resourceName
        self.width = width
        self.height = height
    }
    
    var body: some View {
        if let image = NSImage(named: resourceName) {
            let imageResized = image.scalePreservingAspectRatio(targetSize: NSSize(width: width, height: height))
            Image(nsImage: imageResized)
        } else {
            // Default questionmark if image is not found
            Image(systemName: "questionmark.square")
        }
    }
}

#Preview {
    ResizedImage("NotionLogo", width: 32, height: 32)
}
