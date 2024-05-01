//
//  ImageExtractionSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 20/04/2024.
//

import SwiftUI
import MarkersExtractor

struct ImageExtractionSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    let pickerWidth: CGFloat = 170

    var body: some View {
        VStack(alignment: .formControlAlignment) {
            fileCreationSettingsView

            Divider()

            imageSizeSettingsView

            Divider()

            jpegSettingsView
                .disabled(settings.store.imageMode != .JPG)

            Divider()

            gifSettingsView
                .disabled(settings.store.imageMode != .GIF)
        }
    }

    var fileCreationSettingsView: some View {
        VStack(alignment: .formControlAlignment) {
            Text("File Creation")
                .font(.headline)

            // Naming mode
            LabeledFormElement("Naming Mode") {
                Picker("", selection: $settings.store.IDNamingMode) {
                    ForEach(MarkerIDMode.allCases) { item in
                        Text(item.displayName)
                            .tag(item)
                    }
                }
                .frame(width: self.pickerWidth)
            }

            // Markers source
            LabeledFormElement("Markers Source") {
                Picker("", selection: $settings.store.markersSource) {
                    ForEach(MarkersSource.allCases, id: \.self) { source in
                        Text(source.description)
                    }
                }
                .frame(width: self.pickerWidth)
            }

            // Image format
            LabeledFormElement("Image Format") {
                ImageModePicker()
                    .frame(width: self.pickerWidth)
            }
        }
    }

    var imageSizeSettingsView: some View {
        VStack(alignment: .formControlAlignment) {
            Text("Image Size")
                .font(.headline)

            Picker("", selection: $settings.store.overrideImageSize) {
                Text("Default")
                    .tag(OverrideImageSizeOption.noOverride)

                // Image size percent
                LabeledFormElement("Size (%)") {
                    TextField(
                        "",
                        value: $settings.store.imageSizePercent,
                        format: .number
                    )
                    .frame(width: 50)
                    .onChange(of: settings.store.imageSizePercent) { newValue in
                        settings.store.imageSizePercent = newValue.clamped(to: 1...100)
                    }

                    Text("%")
                        .padding(.leading, -7)

                    Stepper(
                        "",
                        value: $settings.store.imageSizePercent,
                        in: 0...100
                    )
                }
                .padding(.vertical, 6)
                .tag(OverrideImageSizeOption.overrideImageSizePercent)
                .disabled(settings.store.overrideImageSize != OverrideImageSizeOption.overrideImageSizePercent)

                // Image width and height
                VStack {
                    LabeledFormElement("Width") {
                        TextField(
                            "",
                            value: $settings.store.imageWidth,
                            format: .number
                        )
                        .frame(width: 75)
                    }

                    LabeledFormElement("Height:") {
                        TextField(
                            "",
                            value: $settings.store.imageHeight,
                            format: .number
                        )
                        .frame(width: 75)
                    }
                }
                .tag(OverrideImageSizeOption.overrideImageWidthAndHeight)
                .disabled(settings.store.overrideImageSize != .overrideImageWidthAndHeight)
            }
            .pickerStyle(.radioGroup)
            .padding(.bottom, 8)
        }
    }

    var jpegSettingsView: some View {
        VStack(alignment: .formControlAlignment) {
            Text("JPG")
                .font(.headline)

            LabeledFormElement("Quality") {
                TextField(
                    "",
                    value: $settings.store.JPEGImageQuality,
                    format: .percent
                )
                .labelsHidden()
                .frame(width: 50)

                Stepper(
                    "",
                    value: $settings.store.JPEGImageQuality,
                    in: 0...100
                )
                .labelsHidden()
                .padding(.leading, -5.0)
            }
        }
    }

    var gifSettingsView: some View {
        VStack(alignment: .formControlAlignment) {
            Text("GIF")
                .font(.headline)

            LabeledFormElement("FPS") {
                TextField(
                    "",
                    value: $settings.store.GIFFPS,
                    format: .number.precision(.fractionLength(0))
                )
                .frame(width: 50)

                Stepper(
                    "",
                    value: $settings.store.GIFFPS,
                    in: 0...100
                )
                .padding(.leading, -5)
            }

            LabeledFormElement("Span (Sec)") {
                TextField(
                    "",
                    value: $settings.store.GIFLength,
                    format: .number.precision(.fractionLength(0))
                )
                .frame(width: 50)

                Stepper(
                    "",
                    value: $settings.store.GIFLength,
                    in: 0...100
                )
                .padding(.leading, -5)
            }
        }
    }
}
