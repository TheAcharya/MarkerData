//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct GeneralLabelSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var fontSizeBinding: Binding<String> {
        .init(get: {
            "\(settings.store.selectedFontSize)"
        }, set: {
            settings.store.selectedFontSize = Int($0) ?? settings.store.selectedFontSize
        })
    }
    
    var strokeSizeBinding: Binding<String> {
        .init(get: {
            "\(settings.store.selectedStrokeSize)"
        }, set: {
            settings.store.selectedStrokeSize = Int($0) ?? settings.store.selectedStrokeSize
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
                    value: $settings.store.selectedFontSize,
                    in: 6...100,
                    format: .number,
                    textFieldWidth: 50
                )

                ColorPickerOpacitySliderForm(
                    color: $settings.store.selectedFontColor,
                    opacity: $settings.store.selectedFontColorOpacity
                )
            }

            Divider()
                .padding(.vertical, 10)

            Text("Stroke")
                .font(.headline)

            Group {
                HStack {
                    LabeledTextboxStepperForm(
                        label: "Size:",
                        value: $settings.store.selectedStrokeSize,
                        in: 6...100,
                        format: .number,
                        textFieldWidth: 50
                    )
                    .disabled(settings.store.isStrokeSizeAuto)
                    
                    Divider()
                        .frame(height: 16)
                    
                    Toggle("Auto", isOn: $settings.store.isStrokeSizeAuto)
                }
                
                ColorPickerForm(color: $settings.store.selectedStrokeColor)

            }

            Divider()
                .padding(.vertical, 10)

            Text("Alignment")
                .font(.headline)

            Group {

                HStack {
                    Text("Horizontal:")
                    Picker("", selection: $settings.store.selectedHorizonalAlignment) {
                        ForEach(LabelHorizontalAlignment.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .padding(.leading, -8)
                    .formControlLeadingAlignmentGuide()
                    .frame(width: 150)
                }
                HStack {
                    Text("Vertical:")
                    Picker("", selection: $settings.store.selectedVerticalAlignment) {
                        ForEach(LabelVerticalAlignment.allCases) { item in
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
