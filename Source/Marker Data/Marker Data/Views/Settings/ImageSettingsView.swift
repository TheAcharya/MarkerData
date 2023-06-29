//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct ImageSettingsView: View {

    @EnvironmentObject var settingsStore: SettingsStore


    var body: some View {
        VStack(alignment: .formControlAlignment) {
            Group {

                Text("File Creation")
                    .font(.headline)

                HStack {

                    Text("Naming Mode:")

                    //Picker To Change Selected ID Naming Mode
                    Picker("", selection: $settingsStore.selectedIDNamingMode) {
                        ForEach(IdNamingMode.allCases) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 150)
                    .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("Image Format:")

                    //Picker To Change Selected ID Naming Mode
                    ImageModePicker()
                        .labelsHidden()
                        .frame(width: 150)
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
                        value: settingsStore.$imageWidth,
                        format: .emptyOrInt
                    )
                    .labelsHidden()
                    .frame(width: 75)
                    .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("Height:")

                    //Picker To Change Selected ID Naming Mode
                    TextField(
                        "",
                        value: settingsStore.$imageHeight,
                        format: .emptyOrInt
                    )
                    .labelsHidden()
                    .frame(width: 75)
                    .formControlLeadingAlignmentGuide()

                }

                HStack {

                    Text("Size (%):")

                    TextField(
                        "",
                        // text: imageSizeBinding
                        value: settingsStore.$selectedImageSize,
                        format: .percent
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settingsStore.selectedImageSize,
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
                        value: settingsStore.$selectedImageQuality,
                        format: .percent
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settingsStore.selectedImageQuality,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5.0)

                }

            }
            .disabled(settingsStore.selectedImageMode != .JPG)

            Group {

                Divider()

                Text("GIF")
                    .font(.headline)

                HStack {

                    Text("FPS:")

                    TextField(
                        "",
                        value: settingsStore.$selectedGIFFPS,
                        format: .number.precision(.fractionLength(0))
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settingsStore.selectedGIFFPS,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }

                HStack {

                    Text("Span (Sec):")

                    TextField(
                        "",
                        value: settingsStore.$selectedGIFLength,
                        format: .number.precision(.fractionLength(0))
                    )
                    .labelsHidden()
                    .frame(width: 50)
                    .formControlLeadingAlignmentGuide()

                    Stepper(
                        "",
                        value: $settingsStore.selectedGIFLength,
                        in: 0...100
                    )
                    .labelsHidden()
                    .padding(.leading, -5)

                }
            }
            .disabled(settingsStore.selectedImageMode != .GIF)

        }
        .overlayHelpButton(url: settingsStore.imageSettingsURL)
        .navigationTitle("Image Settings")
    }
}

struct ImageSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        ImageSettingsView().environmentObject(settingsStore)
    }
}
