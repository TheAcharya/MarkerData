//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import ColorWell

/// Only use in a Form
struct ColorPickerOpacitySliderForm: View {
    
    @Binding var color: Color
    @Binding var opacity: Double
    
    var body: some View {
        HStack {

            Text("Color & Opacity:")

            ColorWellView(color: $color)
            // .border(.green)
                .formControlLeadingAlignmentGuide()

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
        VStack(alignment: .formControlAlignment) {
            
            // HStack {
            //     // Text("")
            //     // EmptyView()
            //         // .alignmentGuide(.controlAlignment) { d in
            //         //     d[.trailing]
            //         // }
            //
            //     Toggle("toggle", isOn: .constant(true))
            //         // .border(.green)
            //         .alignmentGuide(.controlAlignment) { d in
            //             d[.leading] - verticalSpacing
            //         }
            // }
            
            HStack {
                Text("Color and opacity:")
                ColorWellView(color: .constant(.red))
                    .alignmentGuide(.formControlAlignment) { d in
                        d[.leading]
                    }
                Slider(value: .constant(0))
                    .frame(width: 100)
            }
            
            Toggle("toggle", isOn: .constant(true))
                .alignmentGuide(.formControlAlignment) { d in
                    d[.leading]
                }

            HStack {
                Text("Enter the Label man:")
                TextField("", text: .constant(""))
                    .alignmentGuide(.formControlAlignment) { d in
                        d[.leading]
                    }
                    .frame(width: 150)
            }
            
            HStack {
                Text("Label:")
                TextField("", text: .constant(""))
                    .alignmentGuide(.formControlAlignment) { d in
                        d[.leading]
                    }
                    .frame(width: 150)
            }

            // Button("Button", action: { })
            //
            // Toggle("Boolean", isOn: .constant(true))
            //
            // Picker("Pick Something Please:", selection: .constant(0)) {
            //     ForEach(0..<3) { i in
            //         Text(i, format: .number).tag(i)
            //     }
            // }
            // .frame(width: 300)
            //
            // ColorPickerOpacitySliderForm(
            //     color: $color,
            //     opacity: $opacity
            // )
            
        }
        .border(Color.green)
        .padding()
        .frame(width: 500, height: 500)
    }
    
}
