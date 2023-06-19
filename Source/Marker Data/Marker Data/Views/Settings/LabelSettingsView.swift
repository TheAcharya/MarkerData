//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import ColorWell

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
                        Text("Typeface:")
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
                        
                        // MARK: Color Picker
                        
                        ColorWellView("", color: $settingsStore.selectedFontColor)
                        
                        Slider(
                            value: $settingsStore.selectedFontColorOpacity,
                            in: 0...1
                        )
                        Text(settingsStore.selectedFontColorOpacity, format: .percent)
                        
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
                        
                        // MARK: Color Picker
                        
                        ColorWellView("", color: $settingsStore.selectedStrokeColor)
                        
                        Slider(
                            value: $settingsStore.selectedStrokeColorOpacity,
                            in: 0...1
                        )
                        Text(settingsStore.selectedStrokeColorOpacity, format: .percent)

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
                        Toggle("", isOn: $settingsStore.hideLabelNames)
                            .toggleStyle(CheckboxToggleStyle())
                            .frame(alignment: .leading)
                        Spacer(minLength: 325)
                    }
                }
            }
            
        }
        .overlayHelpButton(url: settingsStore.labelSettingsURL)
        .navigationTitle("Label Settings")
    }
    
}
        
            


@available(macOS 13.0, *)
struct LabelSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    
    static var previews: some View {
        LabelSettingsView()
            .environmentObject(settingsStore)
            // .frame(width: 500, height: 500)
    }
    
}
