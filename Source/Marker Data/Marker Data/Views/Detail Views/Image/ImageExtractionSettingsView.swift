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

    var body: some View {
        Form {
            FileCreationSettingsView()

            ImageSizeSettingsView()

            JpegSettingsView()
                .disabled(settings.store.imageMode != .JPG)

            GifSettingsView()
                .disabled(settings.store.imageMode != .GIF)
        }
    }

    struct FileCreationSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        @State var showNamingModeWarningPopover = false
        
        var body: some View {
            Section(header: SectionHeader("File Creation")) {
                LabeledContent("Naming Mode") {
                    HStack {
                        Picker("Naming Mode", selection: $settings.store.IDNamingMode) {
                            ForEach(MarkerIDMode.allCases) { item in
                                Text(item.displayName)
                                    .tag(item)
                            }
                        }
                        .labelsHidden()
                        .applyPickerSizing()
                        
                        if settings.store.IDNamingMode == .notes && settings.store.markersSource != .markers {
                            Button {
                                showNamingModeWarningPopover = true
                            } label: {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(Color.yellow)
                            }
                            .buttonStyle(.plain)
                            .popover(isPresented: $showNamingModeWarningPopover) {
                                Text("**Incompatible Settings Detected** - The **Naming Mode** is set to **Notes**, which conflicts with **Marker Source** when set to **Marker and Captions** or **Captions**. Please adjust your settings to resolve this conflict.")
                                    .frame(maxWidth: 400, minHeight: 65)
                                    .padding(8)
                            }
                        }
                    }
                }
                
                FixedPicker("Markers Source", selection: $settings.store.markersSource) {
                    ForEach(MarkersSource.allCases, id: \.self) { source in
                        Text(source.description)
                    }
                }
                
                ImageModePicker()
            }
        }
    }

    struct ImageSizeSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("Image Size")) {
                Picker("", selection: $settings.store.overrideImageSize) {
                    Text("Default")
                        .tag(OverrideImageSizeOption.noOverride)
                    
                    HStack {
                        Text("Size (%):")
                        
                        TextField(
                            "",
                            value: $settings.store.imageSizePercent,
                            format: .number
                        )
                        .frame(width: 50)
                        .onChange(of: settings.store.imageSizePercent) { oldValue, newValue in
                            settings.store.imageSizePercent = newValue.clamped(to: 1...100)
                        }
                        
                        Text("%")
                            .padding(.leading, -7)
                        
                        Stepper(
                            "",
                            value: $settings.store.imageSizePercent,
                            in: 0...100
                        )
                        .labelsHidden()
                    }
                    .padding(.vertical, 6)
                    .tag(OverrideImageSizeOption.overrideImageSizePercent)
                    .disabled(settings.store.overrideImageSize != OverrideImageSizeOption.overrideImageSizePercent)
                    
                    VStack {
                        HStack {
                            Text("Width:")
                            TextField(
                                "",
                                value: $settings.store.imageWidth,
                                format: .number
                            )
                            .frame(width: 75)
                        }
                        
                        HStack {
                            Text("Height:")
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
                .labelsHidden()
            }
        }
    }

    struct JpegSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("JPG")) {
                LabeledContent("Quality") {
                    HStack {
                        TextField(
                            "",
                            value: $settings.store.JPEGImageQuality,
                            format: .percent
                        )
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
        }
    }

    struct GifSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        var body: some View {
            Section(header: SectionHeader("GIF")) {
                LabeledContent("FPS") {
                    HStack {
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
                        .labelsHidden()
                        .padding(.leading, -5)
                    }
                }
                
                LabeledContent("Span (Sec)") {
                    HStack {
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
                        .labelsHidden()
                        .padding(.leading, -5)
                    }
                }
            }
        }
    }
    
    struct ImageModePicker: View {
        @EnvironmentObject var settings: SettingsContainer

        var body: some View {
            FixedPicker("Image Format", selection: $settings.store.imageMode) {
                ForEach(ImageMode.allCases) { imageMode in
                    Text(imageMode.displayName).tag(imageMode)
                }
            }
        }
    }
}
