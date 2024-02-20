//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import MarkersExtractor

struct ImageSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    
    let pickerWidth: CGFloat = 170

    var body: some View {
        VStack(alignment: .formControlAlignment) {
            Group {
                Text("File Creation")
                    .font(.headline)
                
                // Naming mode
                HStack {
                    Text("Naming Mode:")

                    //Picker To Change Selected ID Naming Mode
                    Picker("", selection: $settings.store.IDNamingMode) {
                        ForEach(MarkerIDMode.allCases) { item in
                            Text(item.displayName)
                                .tag(item)
                        }
                    }
                    .labelsHidden()
                    .frame(width: self.pickerWidth)
                    .formControlLeadingAlignmentGuide()
                }
                
                // Markers source
                HStack {
                    Text("Markers Source:")
                    
                    Picker("", selection: $settings.store.markersSource) {
                        ForEach(MarkersSource.allCases, id: \.self) { source in
                            Text(source.description)
                        }
                    }
                    .labelsHidden()
                    .frame(width: self.pickerWidth)
                    .formControlLeadingAlignmentGuide()
                }
                
                // Image format
                HStack {
                    Text("Image Format:")

                    //Picker To Change Selected ID Naming Mode
                    ImageModePicker()
                        .labelsHidden()
                        .frame(width: self.pickerWidth)
                        .formControlLeadingAlignmentGuide()
                }
            }

            Group {
                Divider()

                Text("Image Size")
                    .font(.headline)
                
                Picker("", selection: $settings.store.overrideImageSize) {
                    Text("Default")
                        .tag(OverrideImageSizeOption.noOverride)
                    
                    // Image size percent
                    HStack {
                        Text("Size (%):")
                        
                        TextField(
                            "",
                            value: $settings.store.imageSizePercent,
                            format: .percent
                        )
                        .labelsHidden()
                        .frame(width: 50)
                        .formControlLeadingAlignmentGuide()
                        
                        Stepper(
                            "",
                            value: $settings.store.imageSizePercent,
                            in: 0...100
                        )
                        .labelsHidden()
                        .padding(.leading, -5)
                    }
                    .padding(.vertical, 6)
                    .tag(OverrideImageSizeOption.overrideImageSizePercent)
                    .disabled(settings.store.overrideImageSize != OverrideImageSizeOption.overrideImageSizePercent)
                    
                    // Image width and height
                    VStack {
                        HStack {
                            Text("Width:")
                            
                            TextField(
                                "",
                                value: $settings.store.imageWidth,
                                format: .number
                            )
                            .labelsHidden()
                            .frame(width: 75)
                            .formControlLeadingAlignmentGuide()
                        }
                        
                        HStack {
                            Text("Height:")
                            
                            TextField(
                                "",
                                value: $settings.store.imageHeight,
                                format: .number
                            )
                            .labelsHidden()
                            .frame(width: 75)
                            .formControlLeadingAlignmentGuide()
                        }
                    }
                    .tag(OverrideImageSizeOption.overrideImageWidthAndHeight)
                    .disabled(settings.store.overrideImageSize != .overrideImageWidthAndHeight)
                }
                .pickerStyle(.radioGroup)
                .padding(.bottom)
            }

            Group {

                Divider()

                Text("JPG")
                    .font(.headline)

                HStack {

                    Text("Quality:")

                    TextField(
                        "",
                        value: $settings.store.JPEGImageQuality,
                        format: .percent
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.JPEGImageQuality,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5.0)

                }

            }
            .disabled(settings.store.imageMode != .JPG)

            Group {

                Divider()

                Text("GIF")
                    .font(.headline)

                HStack {

                    Text("FPS:")

                    TextField(
                        "",
                        value: $settings.store.GIFFPS,
                        format: .number.precision(.fractionLength(0))
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.GIFFPS,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }

                HStack {

                    Text("Span (Sec):")

                    TextField(
                        "",
                        value: $settings.store.GIFLength,
                        format: .number.precision(.fractionLength(0))
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.GIFLength,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }
            }
            .disabled(settings.store.imageMode != .GIF)

        }
        .overlayHelpButton(url: Links.imageSettingsURL)
        .navigationTitle("Image Settings")
    }
}

struct ImageSettingsView_Previews: PreviewProvider {
    static let settings = SettingsContainer()
    
    static var previews: some View {
        ImageSettingsView()
            .environmentObject(settings)
    }
}
