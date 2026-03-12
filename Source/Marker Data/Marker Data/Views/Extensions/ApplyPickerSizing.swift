//
//  ApplyPickerSizing.swift
//  Marker Data
//
//  Created by Milán Várady on 2026. 03. 10..
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyPickerSizing(width: CGFloat = WindowSize.pickerWidth) -> some View {
        if #available(macOS 26.0, *) {
            self
                .frame(width: width)
                .buttonSizing(.flexible)
        } else {
            self
                .frame(width: width)
        }
    }
}
