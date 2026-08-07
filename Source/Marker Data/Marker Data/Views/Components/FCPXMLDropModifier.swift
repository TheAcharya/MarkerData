//
//  FCPXMLDropModifier.swift
//  Marker Data
//
//  Created by Vigneswaran Rajkumar
//
//
//  Drop handler for FCPXML files, Finder text clippings, and Final Cut Pro pasteboard drags.
//

import SwiftUI
import UniformTypeIdentifiers

struct FCPXMLDropModifier: ViewModifier {
    @ObservedObject var extractionModel: ExtractionModel
    @Binding var isDropTargeted: Bool
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content.onDrop(
            of: [.fcpxml, .fileURL],
            isTargeted: isEnabled ? $isDropTargeted : .constant(false)
        ) { providers in
            guard isEnabled else { return false }
            extractionModel.receiveItemProviders(providers)
            return true
        }
    }
}

extension View {
    func fcpxmlDropDestination(
        extractionModel: ExtractionModel,
        isTargeted: Binding<Bool>,
        isEnabled: Bool = true
    ) -> some View {
        modifier(FCPXMLDropModifier(
            extractionModel: extractionModel,
            isDropTargeted: isTargeted,
            isEnabled: isEnabled
        ))
    }
}
