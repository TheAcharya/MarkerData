//
//  ColorPickerForm.swift
//  Marker Data
//
//  Created by Milán Várady on 13/11/2023.
//

import SwiftUI
import ColorWellKit

struct ColorPickerForm: View {
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Text("Color:")
            
            ColorWell(selection: $color, supportsOpacity: false)
                .colorWellStyle(.minimal)
        }
    }
}

#Preview {
    ColorPickerForm(color: .constant(.white))
}
