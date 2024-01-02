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

            Text("Color & Opacity:")

            ColorWellView(selection: $color, supportsOpacity: false)
                .colorWellStyle(.minimal)

            Slider(value: $opacity, in: 0...1)
                .frame(width: 75)

            TextField(
                "",
                value: $opacity,
                format: .percent.precision(.fractionLength(0))
            )
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .frame(width: 60)

        }
    }
    
    var opacityTextboxStepperForm: some View {
        LabeledTextboxStepperForm(
            label: "",
            value: $opacity,
            in: 0...1,
            format: .percent,
            textFieldWidth: 60
        )
    }

}

struct ColorPickerOpacitySliderForm_Previews: PreviewProvider {
    
    @State static private var color = Color.red
    @State static private var opacity: Double = 1
    
    static let verticalSpacing: CGFloat = 10

    static var previews: some View {
        ColorPickerOpacitySliderForm(
            color: $color,
            opacity: $opacity
        )
        .padding()
    }
    
}
