//
//  ImageSettingsView.swift
//  Marker Data
//
//  Created by Theo S on 10/05/2023.
//

import SwiftUI

struct ImageSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    let intFormatter: NumberFormatter = {
         let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
         return formatter
     }()
    
    var imageSizeBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedImageSize)"
        }, set: {
            settingsStore.selectedImageSize = Int($0) ?? settingsStore.selectedImageSize
        })
    }
    
    var imageQualityBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedImageQuality)"
        }, set: {
            settingsStore.selectedImageQuality = Int($0) ?? settingsStore.selectedImageQuality
        })
    }
    
    var imageGifFFPSBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedGIFFPS)"
        }, set: {
            settingsStore.selectedGIFFPS = Int($0) ?? settingsStore.selectedGIFFPS
        })
    }
    
    var imageGIFLengthSpanBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedGIFLength)"
        }, set: {
            settingsStore.selectedGIFLength = Int($0) ?? settingsStore.selectedGIFLength
        })
    }

    
    var body: some View {
        Form {
            VStack {
                Group {
                    Text("File Creation")
                        .font(.headline)
                    HStack {
                        Text("Naming Mode:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        //Picker To Change Selected ID Naming Mode
                        Picker("", selection: $settingsStore.selectedIDNamingMode) {
                            ForEach(IdNamingMode.allCases, id: \.self) { item in
                                Text(item.displayName).tag(item)
                            }
                        }.labelsHidden()
                            .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    HStack {
                        Text("Image Format:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        //Picker To Change Selected ID Naming Mode
                        ImageModePicker()
                            .labelsHidden()
                            .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    
                }
                Group {
                    Divider()
                    Text("Image Size")
                        .font(.headline)
                    HStack {
                        Text("Width:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        //Picker To Change Selected ID Naming Mode
                        TextField("", value: $settingsStore.imageWidth, formatter: intFormatter)
                            .labelsHidden()
                            .frame(width: 75, alignment: .leading)
                        Spacer(minLength: 275)
                    }
                    HStack {
                        Text("Height:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        //Picker To Change Selected ID Naming Mode
                        TextField("", value: $settingsStore.imageHeight, formatter: intFormatter)
                            .labelsHidden()
                            .frame(width: 75, alignment: .leading)
                        Spacer(minLength: 275)
                    }
                    
                    HStack {
                        Text("Size(%):")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Group {
                            TextField("", text: imageSizeBinding)
                                .labelsHidden()
                                
                                .frame(width: 50, alignment: .leading)
                            Stepper("", value: $settingsStore.selectedImageSize, in: 0...100)
                                .labelsHidden()
                                .padding(.leading, -5.0)
                                .frame(alignment: .leading)
                               
                        }
                        Spacer(minLength: 285)
                    }
                }
                

                Group {
                    Divider()
                    Text("JPG")
                        .font(.headline)
                    HStack {
                        Text("Quality:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Group {
                            TextField("", text: imageQualityBinding)
                                .labelsHidden()
                                
                                .frame(width: 50, alignment: .leading)
                            Stepper("", value: $settingsStore.selectedImageQuality, in: 0...100)
                                .labelsHidden()
                                .padding(.leading, -5.0)
                                .frame(alignment: .leading)
                               
                        }
                        Spacer(minLength: 285)
                    }
                }.disabled(settingsStore.selectedImageMode != .JPG)

                
                Group {
                    Divider()
                    Text("GIF")
                        .font(.headline)
                    HStack {
                        Text("FPS:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Group {
                            TextField("", text: imageGifFFPSBinding)
                                .labelsHidden()
                                
                                .frame(width: 50, alignment: .leading)
                            Stepper("", value: $settingsStore.selectedGIFFPS, in: 0...100)
                                .labelsHidden()
                                .padding(.leading, -5.0)
                                .frame(alignment: .leading)
                               
                        }
                        Spacer(minLength: 285)
                    }
                    
                    HStack {
                        Text("Span (Sec):")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Group {
                            TextField("", text: imageGIFLengthSpanBinding)
                                .labelsHidden()
                                
                                .frame(width: 50, alignment: .leading)
                            Stepper("", value: $settingsStore.selectedGIFLength, in: 0...100)
                                .labelsHidden()
                                .padding(.leading, -5.0)
                                .frame(alignment: .leading)
                               
                        }
                        Spacer(minLength: 285)
                    }
                }.disabled(settingsStore.selectedImageMode != .GIF)
            }
        }
        //Set Navgation Bar Title To Image
        .navigationTitle("Image")
    }
}

struct ImageSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        ImageSettingsView().environmentObject(settingsStore)
    }
}
