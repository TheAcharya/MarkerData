//
//  SwatchSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 20/04/2024.
//

import SwiftUI
import DominantColors

struct SwatchSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    let pickerWidth: CGFloat = 170

    var body: some View {
        VStack(alignment: .formControlAlignment) {
            Text("Color Swatch")
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
        }
    }
}

#Preview {
    SwatchSettingsView()
}
