//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI
import MarkersExtractor

struct GeneralLabelSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var fontSizeBinding: Binding<String> {
        .init(get: {
            "\(settings.store.fontSize)"
        }, set: {
            settings.store.fontSize = Int($0) ?? settings.store.fontSize
        })
    }
    
    var strokeSizeBinding: Binding<String> {
        .init(get: {
            "\(settings.store.strokeSize)"
        }, set: {
            settings.store.strokeSize = Int($0) ?? settings.store.strokeSize
        })
    }
    
    @State var testColor: Color = .white

    var body: some View {
        VStack(alignment: .formControlAlignment) {
            fontSettingsView

            Divider()
                .padding(.vertical, 10)

            strokeSettingsView

            Divider()
                .padding(.vertical, 10)

            alignmentSettingsView
        }
        .navigationTitle("Label Settings")
    }

    var fontSettingsView: some View {
        Group {
            Text("Font")
                .font(.headline)

            LabeledFormElement("Typeface") {
                FontNamePicker()
                    .frame(width: 150)
            }

            LabeledFormElement("Style") {
                FontStylePicker()
                    .frame(width: 150)
            }

            LabeledTextboxStepperForm(
                label: "Size:",
                value: $settings.store.fontSize,
                in: 6...100,
                format: .number,
                textFieldWidth: 50
            )

            // Color & Opacity
            LabeledFormElement("Color & Opacity") {
                ColorPickerOpacitySliderForm(
                    color: $settings.store.fontColor,
                    opacity: $settings.store.fontColorOpacity
                )
            }
        }
    }

    var strokeSettingsView: some View {
        Group {
            Text("Stroke")
                .font(.headline)

            HStack {
                LabeledTextboxStepperForm(
                    label: "Size:",
                    value: $settings.store.strokeSize,
                    in: 0...100,
                    format: .number,
                    textFieldWidth: 50
                )
                .disabled(settings.store.isStrokeSizeAuto)

                Divider()
                    .frame(height: 16)

                Toggle("Auto", isOn: $settings.store.isStrokeSizeAuto)
            }

            ColorPickerForm(color: $settings.store.strokeColor)
        }
    }

    var alignmentSettingsView: some View {
        Group {
            Text("Alignment")
                .font(.headline)

            LabeledFormElement("Horizontal") {
                Picker("", selection: $settings.store.horizonalAlignment) {
                    ForEach(MarkerLabelProperties.AlignHorizontal.allCases) { item in
                        Text(item.displayName).tag(item)
                    }
                }
                .frame(width: 150)
            }

            LabeledFormElement("Vertical") {
                Picker("", selection: $settings.store.verticalAlignment) {
                    ForEach(MarkerLabelProperties.AlignVertical.allCases) { item in
                        Text(item.displayName).tag(item)
                    }
                }
                .frame(width: 150)
            }
        }
    }
}

#Preview {
    let settings = SettingsContainer()

    return GeneralLabelSettingsView()
        .environmentObject(settings)
}
