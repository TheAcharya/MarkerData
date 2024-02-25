//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
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
            Text("Font")
                .font(.headline)

            Group {
                HStack {
                    Text("Typeface:")

                    FontNamePicker()
                        .padding(.leading, -8)
                        .formControlLeadingAlignmentGuide()
                        .frame(width: 150)
                }

                HStack {
                    Text("Style:")
                    
                    FontStylePicker()
                        .padding(.leading, -8)
                        .formControlLeadingAlignmentGuide()
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
                HStack {
                    Text("Color & Opacity:")
                    
                    ColorPickerOpacitySliderForm(
                        color: $settings.store.fontColor,
                        opacity: $settings.store.fontColorOpacity
                    )
                    .formControlLeadingAlignmentGuide()
                }
            }

            Divider()
                .padding(.vertical, 10)

            Text("Stroke")
                .font(.headline)

            Group {
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

            Divider()
                .padding(.vertical, 10)

            Text("Alignment")
                .font(.headline)

            Group {
                HStack {
                    Text("Horizontal:")
                    Picker("", selection: $settings.store.horizonalAlignment) {
                        ForEach(MarkerLabelProperties.AlignHorizontal.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .padding(.leading, -8)
                    .formControlLeadingAlignmentGuide()
                    .frame(width: 150)
                }
                
                HStack {
                    Text("Vertical:")
                    Picker("", selection: $settings.store.verticalAlignment) {
                        ForEach(MarkerLabelProperties.AlignVertical.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .padding(.leading, -8)
                    .formControlLeadingAlignmentGuide()
                    .frame(width: 150)
                }
            }
        }
        .navigationTitle("Label Settings")
    }
}

struct GeneralLabelSettingsView_Previews: PreviewProvider {
    @StateObject static private var settings = SettingsContainer()
    
    static var previews: some View {
        GeneralLabelSettingsView()
            .environmentObject(settings)
    }
}
