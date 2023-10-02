//
//  ExtractionView.swift
//  Marker Data
//
//  Created by Milán Várady on 30/09/2023.
//

import SwiftUI

struct ExtractionView: View {
    @StateObject private var errorViewModel = ErrorViewModel()

    @ObservedObject var extractionModel: ExtractionModel
    @ObservedObject var progressPublisher: ProgressPublisher
   
    @EnvironmentObject var settingsStore: SettingsStore
    
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
                ProgressView(
                    progressPublisher.message,
                    value: progressPublisher.progress.fractionCompleted,
                    total: 1
                )
            }
            
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
        }
        .overlay(UserAlertView(title: "Error", onDismiss: {
                    // Perform any action you want when the user dismisses the alert.
        })
        .environmentObject(extractionModel.errorViewModel))
        .alert(
            "Extracted",
            isPresented: $extractionModel.showOutputInFinder
        ) {
            Button("Show in finder") {
                if let url = extractionModel.completedOutputFolder {
                    NSWorkspace.shared.open(url)
                }
            }
            Button("Ok") { }
        } message: {
            Text("Markers successfully extracted.")
        }
        // .alert(isPresented: $extractionModel.showOutputInFinder) {
        //     Alert(
        //         title: Text("Extracted"),
        //         message: Text("Markers successfully extracted."),
        //         primaryButton: .default(Text("Show in finder")) {
        //             if let url = extractionModel.completedOutputFolder {
        //                 NSWorkspace.shared.open(url)
        //             }
        //         },
        //         secondaryButton: .default(Text("Ok"))
        //     )
        // }
    }
}

#Preview {
    @StateObject  var settingsStore = SettingsStore()

    @StateObject var progressPublisher = ProgressPublisher(
        progress: Progress(totalUnitCount: 100)
    )

    @StateObject var extractionModel = ExtractionModel(
        settingsStore: settingsStore,
        progressPublisher: progressPublisher
    )

    return ExtractionView(
        extractionModel: extractionModel,
        progressPublisher: progressPublisher
    )
    .environmentObject(settingsStore)
}
