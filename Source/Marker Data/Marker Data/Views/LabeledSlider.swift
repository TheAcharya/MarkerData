//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct LabeledSlider<Value, Label, Format>: View where
    Value: BinaryFloatingPoint,
    Value.Stride: BinaryFloatingPoint,
    Label: View,
    Format: ParseableFormatStyle,
    Format.FormatOutput == String,
    Format.FormatInput == Value
{
    
    @Binding var value: Value

    let range: ClosedRange<Value>

    let label: () -> Label

    let format: Format

    init(
        value: Binding<Value>,
        in range: ClosedRange<Value>,
        format: Format,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.range = range
        self.format = format
        self.label = label
    }
    
    var body: some View {
        VStack {
            HStack {
                label()
                TextField("", value: $value, format: format, prompt: nil)
                    .frame(width: 100)
            }
            Slider(value: $value, in: range)
        }
    }
}

extension LabeledSlider where Label == Text {
    
    init(
        value: Binding<Value>,
        in range: ClosedRange<Value>,
        format: Format,
        label: String
    ) {
        self.init(
            value: value,
            in: range,
            format: format,
            label: { Text(label) }
        )
    }

}

struct LabeledSlider_Previews: PreviewProvider {

    @State static var value: Double = 1

    static let range: ClosedRange<Double> = 0...300

    static var previews: some View {
        LabeledSlider(
            value: $value,
            in: range,
            format: .number,
            label: "amount"
        )
        .padding()
        .frame(width: 400)
    }
}
