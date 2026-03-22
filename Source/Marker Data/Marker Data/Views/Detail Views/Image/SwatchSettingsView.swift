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

    var swatchDisabled: Bool {
        if settings.store.unifiedExportProfile.extractProfile == .xlsx {
            return true
        }
        
        let jsonProfiles: [ExportProfileFormat] = [.notion, .airtable]
        let isJSON = jsonProfiles.contains(settings.store.unifiedExportProfile.extractProfile)
        let isGIF = settings.store.imageMode == .GIF

        return !isJSON && isGIF
    }

    var body: some View {
        VStack {
            Form {
                Section(header: SectionHeader("Swatch Analysis")) {
                    Toggle("Enable Swatch", isOn: $settings.store.colorSwatchSettings.enableSwatch)

                    FixedPicker("Algorithm", selection: $settings.store.colorSwatchSettings.algorithm) {
                        ForEach(DeltaEFormula.allCases, id: \.self) { algorithm in
                            Text(algorithm.name)
                                .help(algorithm.description)
                        }
                    }

                    FixedPicker("Accuracy", selection: $settings.store.colorSwatchSettings.accuracy) {
                        ForEach(DominantColorQuality.allCases, id: \.self) { accuracy in
                            Text(accuracy.rawValue.titleCased)
                        }
                    }

                    Toggle("Exclude Black", isOn: $settings.store.colorSwatchSettings.excludeBlack)

                    Toggle("Exclude Grey", isOn: $settings.store.colorSwatchSettings.excludeGray)

                    Toggle("Exclude White", isOn: $settings.store.colorSwatchSettings.excludeWhite)
                }
            }

            if swatchDisabled {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")

                    Text("The currently selected Export Profile and Image Format are incompatible.")
                }
                .padding(8)
                .background(.black)
                .clipShape(.rect(cornerRadius: 8))
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
