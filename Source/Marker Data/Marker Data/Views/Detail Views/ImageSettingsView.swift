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
                    Picker("", selection: $settings.store.selectedIDNamingMode) {
                        ForEach(IdNamingMode.allCases) { item in
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

                HStack {

                    Text("Width:")

                    // Picker To Change Selected ID Naming Mode
                    TextField(
                        "",
                        value: $settings.store.imageWidth,
                        format: .emptyOrInt
                    )
                    .labelsHidden()
                    .frame(width: 75)
                    .formControlLeadingAlignmentGuide()

                    Toggle("", isOn: $settings.store.imageWidthEnabled)

                }

                HStack {

                    Text("Height:")

                    //Picker To Change Selected ID Naming Mode
                    TextField(
                        "",
                        value: $settings.store.imageHeight,
                        format: .emptyOrInt
                    )
                    .labelsHidden()
                    .frame(width: 75)
                    .formControlLeadingAlignmentGuide()

                    Toggle("", isOn: $settings.store.imageHeightEnabled)

                }

                HStack {

                    Text("Size (%):")

                    TextField(
                        "",
                        // text: imageSizeBinding
                        value: $settings.store.selectedImageSize,
                        format: .percent
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.selectedImageSize,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }
            }


            Group {

                Divider()

                Text("JPG")
                    .font(.headline)

                HStack {

                    Text("Quality:")

                    TextField(
                        "",
                        value: $settings.store.selectedImageQuality,
                        format: .percent
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.selectedImageQuality,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5.0)

                }

            }
            .disabled(settings.store.selectedImageMode != .JPG)

            Group {

                Divider()

                Text("GIF")
                    .font(.headline)

                HStack {

                    Text("FPS:")

                    TextField(
                        "",
                        value: $settings.store.selectedGIFFPS,
                        format: .number.precision(.fractionLength(0))
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.selectedGIFFPS,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }

                HStack {

                    Text("Span (Sec):")

                    TextField(
                        "",
                        value: $settings.store.selectedGIFLength,
                        format: .number.precision(.fractionLength(0))
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settings.store.selectedGIFLength,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }
            }
            .disabled(settings.store.selectedImageMode != .GIF)

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
