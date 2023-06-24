//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

/// Only designed for use in forms
struct LabeledTextboxStepperForm<Value, Label, Format>: View where
    Value: Strideable,
    Label: View,
    Format: ParseableFormatStyle,
    Format.FormatOutput == String,
    Format.FormatInput == Value
{
    
    @Binding var value: Value

    let range: ClosedRange<Value>
    let label: () -> Label
    let format: Format
    let textFieldWidth: CGFloat?

    init(
        value: Binding<Value>,
        in range: ClosedRange<Value>,
        format: Format,
        textFieldWidth: CGFloat? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self._value = value
        self.range = range
        self.format = format
        self.textFieldWidth = textFieldWidth
        self.label = label
    }
    
    var body: some View {
        TextField(value: $value, format: format, label: label)
            .padding(.trailing, 20)
            .frame(width: (textFieldWidth ?? 100) + 20)
            .overlay(alignment: .trailing) {
                Stepper("", value: $value)
            }
    }
}

extension LabeledTextboxStepperForm where Label == Text {
    
    init(
        label: String,
        value: Binding<Value>,
        in range: ClosedRange<Value>,
        format: Format,
        textFieldWidth: CGFloat? = nil
    ) {
        self.init(
            value: value,
            in: range,
            format: format,
            textFieldWidth: textFieldWidth,
            label: { Text(label) }
        )
    }

}

struct LabeledTextboxStepperForm_Previews: PreviewProvider {

    @State static var value: Double = 100

    static let range: ClosedRange<Double> = 0...300

    static var previews: some View {
        Form {
            LabeledTextboxStepperForm(
                label: "amount:",
                value: $value,
                in: range,
                format: .number,
                textFieldWidth: 100
            )
            .padding()
        }
        .frame(width: 400)
    }
}
