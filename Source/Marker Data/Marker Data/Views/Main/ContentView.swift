//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
import MarkersExtractor

struct ContentView: View {
    
    @EnvironmentObject var settingsStore: SettingsStore

    @StateObject private var errorViewModel = ErrorViewModel()

    @ObservedObject var extractionModel: ExtractionModel
    @ObservedObject var progressPublisher: ProgressPublisher

    @State private var showingOutputInfinder = false
    @State private var completedOutputFolder: URL? = nil

    //Main View Controller
    var body: some View {
        VStack {
            //Drag And Drop File Zone
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    //Text Prompt To Drop Final Cut Pro XML File
                    Text("Drag and Drop FCP XML")
                        .bold()
                        .font(.title2)
                    Spacer()
                }
                Spacer()
            }
            //Handle The Drop Of A File Or URL And Run The CLI Tool Library
            .onDrop(
                of: ExtractionModel.supportedContentTypes,
                delegate: extractionModel
            )

            // .onDrop(of: [(kUTTypeFileURL as String)], isTargeted: nil, perform: { providers, _ in
            //
            //     DispatchQueue.main.async {
            //         progressPublisher.showProgress = true
            //         progressPublisher.updateProgressTo(progressMessage: "Received file", percentageCompleted: 1)
            //     }
            //     self.completedOutputFolder = nil
            //     for provider in providers {
            //         //UserDefaults.standard.set(nil, forKey:exportFolderPathKey)
            //         // Check if the provider can load a file URL
            //         if provider.canLoadObject(ofClass: URL.self) {
            //             // Load the file URL from the provider
            //             let _ = provider.loadObject(ofClass: URL.self) { url, error in
            //                 if let fileURL = url {
            //                     // Handle the file URL
            //                     print("Dropped file URL: \(fileURL.absoluteString)")
            //                     progressPublisher.updateProgressTo(
            //                         progressMessage: "Begin to process file \(fileURL.absoluteString) ",
            //                         percentageCompleted: 2
            //                     )
            //                     DispatchQueue.global(qos: .background).async {
            //                         do {
            //                             let settings = try settingsStore.markersExtractorSettings(
            //                                 fcpxmlFileUrl: fileURL
            //                             )
            //                             progressPublisher.updateProgressTo(
            //                                 progressMessage: "Extraction in progress...",
            //                                 percentageCompleted: 2
            //                             )
            //                             try MarkersExtractor(settings).extract()
            //                             progressPublisher.updateProgressTo(
            //                                 progressMessage: "Extraction successful",
            //                                 percentageCompleted: 100
            //                             )
            //                             self.completedOutputFolder = settings.outputDir
            //                             showingOutputInfinder = true // inform the user
            //                             print("Ok")
            // 
            //                         } catch {
            //                             DispatchQueue.main.async {
            //                                 progressPublisher.markasFailed(
            //                                     errorMessage: "Error: \(error.localizedDescription)"
            //                                 )
            //
            //                                 errorViewModel.errorMessage  = error.localizedDescription
            //                                 print("Error: \(error.localizedDescription)")
            //                             }
            // 
            //                         }
            //                     }
            //                 } else if let error = error {
            //                     // Handle the error
            //                     DispatchQueue.main.async {
            //                         progressPublisher.markasFailed(
            //                             errorMessage: "Error: \(error.localizedDescription)"
            //                         )
            //                         errorViewModel.errorMessage  = error.localizedDescription
            //                         print("Error: \(error.localizedDescription)")
            //                     }
            //                 }
            //             }
            //         }
            //     }
            //     return true
            // })


            if progressPublisher.showProgress {
                ProgressView(progressPublisher.message, value: progressPublisher.progress.fractionCompleted, total: 1)            }
            
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
                ExportFormatPicker()
                Toggle("Upload", isOn: $settingsStore.isUploadEnabled)
                    .toggleStyle(CheckboxToggleStyle())
                ExcludedRolesPicker()
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

    @StateObject static private var settingsStore = SettingsStore()

    @StateObject static private var progressPublisher = ProgressPublisher(
        progress: Progress(totalUnitCount: 100)
    )

    @StateObject static private var extractionModel = ExtractionModel(
        settingsStore: Self.settingsStore,
        progressPublisher: progressPublisher
    )

    static var previews: some View {
        ContentView(
            extractionModel: extractionModel,
            progressPublisher: progressPublisher
        )
        .environmentObject(settingsStore)
    }
}
