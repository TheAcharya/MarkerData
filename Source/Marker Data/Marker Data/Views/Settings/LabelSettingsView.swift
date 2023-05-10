//
//  LabelSettingsView.swift
//  Marker Data
//
//  Created by Theo S on 10/05/2023.
//

import SwiftUI

struct LabelSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    var body: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Button To Open Font Picker Component
                    //FontPicker("Font", selection: fontBinding)
                    //Text("\($settingsStore.selectedFontName), size: \(Int($settingsStore.selectedFontSize))")
                        //.font(Font(settingsStore.selectedFont))
                    //Picker To Change Horizonal Alignment
                    Picker("Horizonal Alignment", selection: $settingsStore.selectedHorizonalAlignment) {
                        ForEach(LabelHorizontalAlignment.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    //Picker To Change Vertical Alignment
                    Picker("Vertical Alignment", selection: $settingsStore.selectedVerticalAlignment) {
                        ForEach(LabelVerticalAlignment.allCases, id: \.self) { item in
                            Text(item.displayName).tag(item)
                        }
                    }
                    //Text Field To Enter Copyright
                    TextField("Copyright", text: $settingsStore.copyrightText)
                    //Label Tag Chips
//                    HStack {
//                        Text("Labels")
//                        ChipsContent(viewModel: viewModel)
//                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
        }
        //Set Navigation Bar Title To Label
        .navigationTitle("Label")
    }
}

struct LabelSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        LabelSettingsView().environmentObject(settingsStore)
    }
}
