//
//  LabeledFormElement.swift
//  Marker Data
//
//  Created by Milán Várady on 01/05/2024.
//

import SwiftUI

/// A container for attaching a centered label to a form view.
struct LabeledFormElement<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        // Add ":" to label if necessary
        self.label = label.hasSuffix(":") ? label : "\(label):"
        self.content = content()
    }

    var body: some View {
        HStack {
            Text(label)

            HStack {
                self.content
            }
            .labelsHidden()
            .formControlLeadingAlignmentGuide()
        }
    }
}
