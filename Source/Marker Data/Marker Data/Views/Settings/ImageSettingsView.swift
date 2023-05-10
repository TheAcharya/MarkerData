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
    
    var body: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Picker To Change Selected ID Naming Mode
                    Picker("ID Naming Mode", selection: $settingsStore.selectedIDNamingMode) {
                        ForEach(IdNamingMode.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    //Picker To Change Selected Image Mode
                    Picker("Image Mode", selection: $settingsStore.selectedImageMode) {
                        ForEach(ImageMode.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    //Slider To Set JPG Image Quality
                    Slider(value: $settingsStore.selectedImageQuality, in: 1...100, step: 1) {
                            Text("Image Quality")
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("100")
                        } onEditingChanged: { editing in
                            print("Changed JPG Quality To \(settingsStore.selectedImageQuality)")
                        }
                    //Display Text To Show The Current Image Quality
                    Text("Current Image Quality - \(settingsStore.selectedImageQuality)".dropLast(2))
                        .bold()
                    //Text Fields To Set Image Width And Height
                    HStack {
                        TextField("Image Width", value: $settingsStore.imageWidth, formatter: intFormatter)
                            .padding(.trailing)
                        TextField("Image Height", value: $settingsStore.imageHeight, formatter: intFormatter)
                    }
                    //Slider To Set Image Size In Percentages
                    Slider(value: $settingsStore.selectedImageSize, in: 1...100, step: 1) {
                            Text("Image Size (%)")
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("100")
                        } onEditingChanged: { editing in
                            print("Changed Image Size To \($settingsStore.selectedImageSize)")
                        }
                    //Display Text To Show Current Image Size In %
                    Text("Current Image Size - \(settingsStore.selectedImageSize)".dropLast(2))
                        .bold()
                    //Text Field To Set GIF FPS Rate
                    TextField("GIF FPS", value: $settingsStore.selectedGIFFPS, formatter: intFormatter)
                    //Text Field To Set GIF Time Span
                    TextField("GIF Span (Sec)", value: $settingsStore.selectedGIFLength, formatter: intFormatter)
                }
                Spacer()
            }
            .padding(.horizontal)
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
