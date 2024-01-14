//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import ColorWellKit

/// Only use in a Form
struct ColorPickerOpacitySliderForm: View {
    @Binding var color: Color
    @Binding var opacity: Double
    
    var body: some View {
        HStack {
            ColorWell(selection: $color, supportsOpacity: false)
                .colorWellStyle(.minimal)

            Slider(value: $opacity, in: 0...100)
                .frame(width: 75)
            
            Text("\(Int(opacity))%")
        }
    }
}

struct ColorPickerOpacitySliderForm_Previews: PreviewProvider {
    @State static private var color = Color.red
    @State static private var opacity: Double = 100
    
    static let verticalSpacing: CGFloat = 10

    static var previews: some View {
        ColorPickerOpacitySliderForm(
            color: $color,
            opacity: $opacity
        )
        .padding()
    }
    
}
