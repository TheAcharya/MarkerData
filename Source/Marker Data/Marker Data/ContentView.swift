//
//  ContentView.swift
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
import MarkersExtractor

struct ContentView: View {
    
    @StateObject private var errorViewModel = ErrorViewModel()
    
    @State private var showingOutputInfinder = false
    @State private var completedOutputFolder: URL?=nil
    
    @EnvironmentObject var settingsStore: SettingsStore
    
    
    //Is Enable Upload Toggle On
    @State public var isUploadEnabled = false

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
            
                .onDrop(of: [(kUTTypeFileURL as String)], isTargeted: nil, perform: { providers, _ in
                    self.completedOutputFolder = nil
                    for provider in providers {
                        //UserDefaults.standard.set(nil, forKey:exportFolderPathKey)
                        // Check if the provider can load a file URL
                        if provider.canLoadObject(ofClass: URL.self) {
                            // Load the file URL from the provider
                            let _ = provider.loadObject(ofClass: URL.self) { url, error in
                                if let fileURL = url {
                                    // Handle the file URL
                                    print("Dropped file URL: \(fileURL.absoluteString)")
                                    DispatchQueue.main.async {
                                        do {
                                            let outputDirURL: URL = UserDefaults.standard.exportFolder
                                            let settings = try MarkersExtractor.Settings(
                                                fcpxml: .init(fileURL),
                                                outputDir: outputDirURL,
                                                exportFormat: settingsStore.selectedExportFormat.markersExtractor,
                                                imageFormat: settingsStore.selectedImageMode.markersExtractor,
                                                excludeRoleType: settingsStore.selectedExcludeRoles.markersExtractor
                                            )
                                            print("output is going to \(settings.outputDir)")
                                            try MarkersExtractor(settings).extract()
                                            self.completedOutputFolder = outputDirURL
                                            showingOutputInfinder = true
                                            print("Ok")
                                            
                                        } catch {
                                            DispatchQueue.main.async {
                                                errorViewModel.errorMessage  = error.localizedDescription
                                                print("Error: \(error.localizedDescription)")
                                            }
                                            
                                        }
                                    }
                                } else if let error = error {
                                    // Handle the error
                                    print("Error loading file URL: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
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
                ExportFormatPicker()
                //Choose Exclude Roles
                ExcludedRolesPicker()
                //Choose Image Format
                ImageModePicker()
                Spacer()
            }
            .padding(.bottom)
        }.overlay(UserAlertView(title: "Error", onDismiss: {
                    // Perform any action you want when the user dismisses the alert.
        }).environmentObject(errorViewModel))
        .alert(isPresented:$showingOutputInfinder) {
            Alert(
                title: Text("Extracted"),
                message: Text("Markers successfully extracted."),
                primaryButton: .default(Text("Show in finder")) {
                    if let url =  completedOutputFolder {
                        NSWorkspace.shared.open(url)
                    }
                },
                secondaryButton: .default(Text("Ok"))
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
