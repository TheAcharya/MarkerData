//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI
import MarkersExtractor
import ColorWellKit

struct GeneralLabelSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    var body: some View {
        Form {
            FontSettingsView()
            StrokeSettingsView()
            AlignmentSettingsView()
        }
    }

    struct FontSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("Font")) {
                LabeledContent("Typeface") {
                    FontNamePicker()
                        .labelsHidden()
                }
                
                LabeledContent("Style") {
                    FontStylePicker()
                }
                
                LabeledContent("Size") {
                    HStack {
                        TextField(
                            "",
                            value: $settings.store.fontSize,
                            format: .number
                        )
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                        
                        Stepper(
                            "",
                            value: $settings.store.fontSize,
                            in: 6...100
                        )
                        .labelsHidden()
                    }
                }
                
                LabeledContent("Color & Opacity") {
                    ColorPickerOpacitySliderForm(
                        color: $settings.store.fontColor,
                        opacity: $settings.store.fontColorOpacity
                    )
                    .labelsHidden()
                }
            }
        }
    }

    struct StrokeSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("Stroke")) {
                LabeledContent("Size") {
                    HStack {
                        TextField(
                            "",
                            value: $settings.store.strokeSize,
                            format: .number
                        )
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                        
                        Stepper(
                            "",
                            value: $settings.store.strokeSize,
                            in: 0...100
                        )
                        .labelsHidden()
                        .padding(.leading, -10)
                        
                        Divider()
                            .frame(height: 16)
                        
                        Toggle("Auto", isOn: $settings.store.isStrokeSizeAuto)
                    }
                    .disabled(settings.store.isStrokeSizeAuto)
                }
                
                LabeledContent("Color") {
                    ColorWell(selection: $settings.store.strokeColor, supportsOpacity: false)
                        .colorWellStyle(.minimal)
                }
            }
        }
    }

    struct AlignmentSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("Alignment")) {
                FixedPicker("Horizontal", selection: $settings.store.horizonalAlignment) {
                    ForEach(MarkerLabelProperties.AlignHorizontal.allCases) { item in
                        Text(item.displayName).tag(item)
                    }
                }
                
                FixedPicker("Vertical", selection: $settings.store.verticalAlignment) {
                    ForEach(MarkerLabelProperties.AlignVertical.allCases) { item in
                        Text(item.displayName).tag(item)
                    }
                }
            }
        }
    }
    
    struct FontNamePicker: View {
        @EnvironmentObject var settings: SettingsContainer

        var body: some View {
            FixedPicker("Typeface", selection: $settings.store.fontNameType) {
                ForEach(FontNameType.allCases) { fontNameType in
                    Text(fontNameType.displayName).tag(fontNameType)
                }
            }
        }
    }
    
    struct FontStylePicker: View {
        @EnvironmentObject var settings: SettingsContainer

        var body: some View {
            Picker("Style", selection: $settings.store.fontStyleType) {
                ForEach(FontStyleType.allCases) { fontStyleType in
                    Text(fontStyleType.displayName).tag(fontStyleType)
                }
            }
            .labelsHidden()
            .applyPickerSizing()
        }
    }
}

#Preview {
    let settings = SettingsContainer()

    return GeneralLabelSettingsView()
        .environmentObject(settings)
}
