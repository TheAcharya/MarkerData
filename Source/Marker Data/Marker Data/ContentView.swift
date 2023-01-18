//
//  ContentView.swift
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct ContentView: View {
    //Is Enable Upload Toggle On
    @State public var isUploadEnabled = false
    //Selected Export Format Tag For Picker
    @State var selectedExportFormat = 1
    //Selected Exclude Roles Tag For Picker
    @State var selectedExcludeRoles = 1
    //Selected Image Format Tag For Picker
    @State var selectedImageFormat = 1
    //Main View Controller
    var body: some View {
        VStack {
            //Drag And Drop File Zone
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    //Text Prompt To Drop Final Cut Pro XML File
                    Text("Drop A .fcpxml(d) File Here...")
                        .bold()
                        .font(.title2)
                    Spacer()
                }
                Spacer()
            }
            //Handle The Drop Of A File Or URL And Run The CLI Tool
                .onDrop(of: [.item, .fileURL], isTargeted: nil, perform: { providers, _ in
                    print("File Dropped")
                    try! Process.run(Bundle.main.url(forResource: "markers-extractor-cli", withExtension: "")!, arguments: ["--version"], terminationHandler: nil)
                    return true
                })
            //Divide Drag And Drop Zone From Quick Actions
            Divider()
            //Quick Access Title
            Text("Quick Access")
                .bold()
                .padding()
            //Quick Actions
            HStack {
                Spacer()
                //Enable Upload Checkbox
                Toggle("Enable Upload", isOn: $isUploadEnabled)
                    .toggleStyle(CheckboxToggleStyle())
                //Choose Export Format
                Picker("Export Format", selection: $selectedExportFormat) {
                    Text("Notion")
                        .tag(1)
                    Text("Airtable")
                        .tag(2)
                }
                //Choose Exclude Roles
                Picker("Exclude Roles", selection: $selectedExcludeRoles) {
                    Text("None")
                        .tag(1)
                    Text("Video")
                        .tag(2)
                    Text("Audio")
                        .tag(3)
                }
                //Choose Image Format
                Picker("Image Format", selection: $selectedImageFormat) {
                    Text("PNG")
                        .tag(1)
                    Text("JPG")
                        .tag(2)
                    Text("GIF")
                        .tag(3)
                }
                Spacer()
            }
            .padding(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
