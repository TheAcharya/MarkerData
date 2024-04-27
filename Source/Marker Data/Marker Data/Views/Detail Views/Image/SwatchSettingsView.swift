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
            HStack {
                Text("Enable Swatch:")

                Toggle("", isOn: $settings.store.colorSwatchSettings.enableSwatch)
                    .toggleStyle(CheckboxToggleStyle())
                    .formControlLeadingAlignmentGuide()
            }

            // Algorithm
            HStack {
                Text("Algorithm:")

                Picker("", selection: $settings.store.colorSwatchSettings.algorithm) {
                    ForEach(DeltaEFormula.allCases, id: \.self) { algorithm in
                        Text(algorithm.name)
                            .help(algorithm.description)
                    }
                }
                .labelsHidden()
                .frame(width: self.pickerWidth)
                .formControlLeadingAlignmentGuide()
            }

            // Exclude black
            HStack {
                Text("Exclude Black:")

                Toggle("", isOn: $settings.store.colorSwatchSettings.excludeBlack)
                    .toggleStyle(CheckboxToggleStyle())
                    .formControlLeadingAlignmentGuide()
            }

            // Exclude white
            HStack {
                Text("Exclude White:")

                Toggle("", isOn: $settings.store.colorSwatchSettings.excludeWhite)
                    .toggleStyle(CheckboxToggleStyle())
                    .formControlLeadingAlignmentGuide()
            }

            if swatchDisabled {
                Text("**Swatch unavailable:** The currently selected export profile and GIF image format are incompatible.")
                    .padding(.top)
                    .frame(maxWidth: 320)
            }
        }
        .disabled(swatchDisabled)
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()

    return SwatchSettingsView()
        .environmentObject(settings)
        .preferredColorScheme(.dark)
}
