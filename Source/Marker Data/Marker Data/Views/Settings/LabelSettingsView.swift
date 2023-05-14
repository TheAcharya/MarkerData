//
//  LabelSettingsView.swift
//  Marker Data
//
//  Created by Theo S on 10/05/2023.
//

import SwiftUI

struct LabelSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    let intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var fontSizeBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedFontSize)"
        }, set: {
            settingsStore.selectedFontSize = Int($0) ?? settingsStore.selectedFontSize
        })
    }
    
    var strokeSizeBinding: Binding<String> {
        .init(get: {
            "\(settingsStore.selectedStrokeSize)"
        }, set: {
            settingsStore.selectedStrokeSize = Int($0) ?? settingsStore.selectedStrokeSize
        })
    }

    
    var body: some View {
        Form {
            
            VStack {
                Group {
                    Text("Font")
                        .font(.headline)
                    HStack {
                        Text("Type face:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        FontNamePicker()
                            .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    HStack {
                        Text("Style:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        FontStylePicker()
                            .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    HStack {
                        Text("Size:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Group {
                            TextField("", text: fontSizeBinding)
                                .frame(width: 50, alignment: .leading)
                            Stepper("", value: $settingsStore.selectedFontSize, in: 6...100).padding(.leading, -10.0).frame(alignment: .leading)
                        }
                        Spacer(minLength: 280)
                    }
                    
                    HStack {
                        Text("Colour & Opacity:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        ColorPicker("", selection: $settingsStore.selectedFontColor).frame(width: 50, alignment: .leading)
                        
                        Spacer(minLength: 300)
                    }
                }
               
                Group {
                    Divider()
                    Text("Stroke")
                        .font(.headline)
                    HStack {
                        Text("Size:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Group {
                            TextField("", text: strokeSizeBinding)
                                .frame(width: 50, alignment: .leading)
                            Stepper("", value: $settingsStore.selectedStrokeSize, in: 0...100).padding(.leading, -10.0).frame(alignment: .leading)
                        }
                        Spacer(minLength: 280)
                    }
                    HStack {
                        Text("Colour & Opacity:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        ColorPicker("", selection: $settingsStore.selectedStrokeColor).frame(width: 50, alignment: .leading)
                        Spacer(minLength: 300)
                    }
                }
                
                Group {
                    Divider()
                    Text("Alignment")
                        .font(.headline)
                    HStack {
                        Text("Horizontal:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Picker("", selection: $settingsStore.selectedHorizonalAlignment) {
                            ForEach(LabelHorizontalAlignment.allCases, id: \.self) { item in
                                Text(item.displayName).tag(item)
                            }
                        }
                        .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                    HStack {
                        Text("Vertical:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Picker("", selection: $settingsStore.selectedVerticalAlignment) {
                            ForEach(LabelVerticalAlignment.allCases, id: \.self) { item in
                                Text(item.displayName).tag(item)
                            }
                        }
                        .frame(width: 150, alignment: .leading)
                        Spacer(minLength: 200)
                    }
                }
                
               
                Group {
                    Divider()
                    Text("Labels")
                        .font(.headline)

                    HStack {
                        Text("Overlays:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        TextField("", text: $settingsStore.overlaysText)
                        .frame(width: 250, alignment: .leading)
                        Spacer(minLength: 100)
                    }
                    HStack {
                        Text("Copyright:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        TextField("", text: $settingsStore.copyrightText)
                        .frame(width: 250, alignment: .leading)
                        Spacer(minLength: 100)
                    }
                    HStack {
                        Text("Hide Label Names:")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Spacer(minLength: 15)
                        Toggle("", isOn: settingsStore.$hideLabelNames)
                            .toggleStyle(CheckboxToggleStyle())
                            .frame(alignment: .leading)
                        Spacer(minLength: 325)
                    }
                }
            }
            
        }
        
    }
    
}
        
            


struct LabelSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        LabelSettingsView().environmentObject(settingsStore)
    }
}
