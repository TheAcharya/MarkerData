//
//  FixedPicker.swift
//  Marker Data
//
//  Created by Milán Várady on 2026. 03. 11..
//

import SwiftUI

struct FixedPicker<SelectionValue: Hashable, Content: View>: View {
    let label: LocalizedStringKey
    @Binding var selection: SelectionValue
    var width: CGFloat = WindowSize.pickerWidth
    @ViewBuilder var content: () -> Content
    
    init(
        _ label: LocalizedStringKey,
        selection: Binding<SelectionValue>,
        width: CGFloat = WindowSize.pickerWidth,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self._selection = selection
        self.width = width
        self.content = content
    }

    var body: some View {
        LabeledContent(label) {
            Picker(label, selection: $selection) {
                content()
            }
            .labelsHidden()
            .applyPickerSizing(width: width)
        }
    }
}
