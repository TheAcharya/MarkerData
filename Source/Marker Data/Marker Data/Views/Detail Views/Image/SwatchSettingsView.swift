//
//  SwatchSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 20/04/2024.
//

import SwiftUI
import DominantColors
import MarkersExtractor

struct SwatchSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    let pickerWidth: CGFloat = 170

    var swatchDisabled: Bool {
        let jsonProfiles: [ExportProfileFormat] = [.notion, .airtable]
        let isJSON = jsonProfiles.contains(settings.store.unifiedExportProfile.extractProfile)
        let isGIF = settings.store.imageMode == .GIF

        return !isJSON && isGIF
    }

    var body: some View {
        VStack(alignment: .formControlAlignment) {
            Text("Swatch Analysis")
                .font(.headline)

            // Enable
            LabeledFormElement("Enable Swatch") {
                Toggle("", isOn: $settings.store.colorSwatchSettings.enableSwatch)
                    .toggleStyle(CheckboxToggleStyle())
            }

            // Algorithm
            LabeledFormElement("Algorithm") {
                Picker("", selection: $settings.store.colorSwatchSettings.algorithm) {
                    ForEach(DeltaEFormula.allCases, id: \.self) { algorithm in
                        Text(algorithm.name)
                            .help(algorithm.description)
                    }
                }
                .frame(width: self.pickerWidth)
            }

            // Accuracy
            LabeledFormElement("Accuracy") {
                Picker("", selection: $settings.store.colorSwatchSettings.accuracy) {
                    ForEach(DominantColorQuality.allCases, id: \.self) { accuracy in
                        Text(accuracy.rawValue.titleCased)
                    }
                }
                .frame(width: self.pickerWidth)
            }


            // Exclude black
            LabeledFormElement("Exclude Black") {
                Toggle("", isOn: $settings.store.colorSwatchSettings.excludeBlack)
                    .toggleStyle(CheckboxToggleStyle())
            }

            // Exclude gray
            LabeledFormElement("Exclude Grey") {
                Toggle("", isOn: $settings.store.colorSwatchSettings.excludeGray)
                    .toggleStyle(CheckboxToggleStyle())
            }

            // Exclude white
            LabeledFormElement("Exclude White") {
                Toggle("", isOn: $settings.store.colorSwatchSettings.excludeWhite)
                    .toggleStyle(CheckboxToggleStyle())
            }

            if swatchDisabled {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")

                    Text("The currently selected Export Profile and Image Format are incompatible.")
                }
                .padding(8)
                .background(.black)
                .cornerRadius(8)
                .frame(maxWidth: 520)
                .padding(.top)
			}
        }
        .disabled(swatchDisabled)
    }
}

#Preview {
    let settings = SettingsContainer()

    return SwatchSettingsView()
        .environmentObject(settings)
        .preferredColorScheme(.dark)
}
