//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import ColorWell

struct GeneralLabelSettingsView: View {

    @EnvironmentObject var settingsStore: SettingsStore

    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var fontSizeBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedFontSize)"
        }, set: {
            settingsStore.selectedFontSize = Int($0) ?? settingsStore.selectedFontSize
        })
    }
    
    var strokeSizeBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedStrokeSize)"
        }, set: {
            settingsStore.selectedStrokeSize = Int($0) ?? settingsStore.selectedStrokeSize
        })
    }

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
                        // .border(.green)
                }

                HStack {
                    Text("Style:")
                    FontStylePicker()
                        .padding(.leading, -8)
                        .formControlLeadingAlignmentGuide()
                        .frame(width: 150)
                        // .border(.green)
                }


                LabeledTextboxStepperForm(
                    label: "Size:",
                    value: settingsStore.$selectedFontSize,
                    in: 6...100,
                    format: .number,
                    textFieldWidth: 50
                )

                ColorPickerOpacitySliderForm(
                    color: $settingsStore.selectedFontColor,
                    opacity: settingsStore.$selectedFontColorOpacity
                )

            }

            Divider()
                .padding(.vertical, 10)

            Text("Stroke")
                .font(.headline)

            Group {

                LabeledTextboxStepperForm(
                    label: "Size:",
                    value: settingsStore.$selectedStrokeSize,
                    in: 6...100,
                    format: .number,
                    textFieldWidth: 50
                )

                ColorPickerOpacitySliderForm(
                    color: $settingsStore.selectedStrokeColor,
                    opacity: settingsStore.$selectedStrokeColorOpacity
                )

            }

            Divider()
                .padding(.vertical, 10)

            Text("Alignment")
                .font(.headline)

            Group {

                HStack {
                    Text("Horizontal:")
                    Picker("", selection: $settingsStore.selectedHorizonalAlignment) {
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
                    Picker("", selection: $settingsStore.selectedVerticalAlignment) {
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
        .overlayHelpButton(url: settingsStore.labelSettingsURL)
        .navigationTitle("Label Settings")
    }
    
}

struct GeneralLabelSettingsView_Previews: PreviewProvider {

    @StateObject static private var settingsStore = SettingsStore()
    
    static var previews: some View {
        GeneralLabelSettingsView()
            .environmentObject(settingsStore)
            // .frame(width: 500, height: 500)
    }
    
}
