//
//  ExtractView.swift
//  Marker Data
//
//  Created by Milán Várady on 30/09/2023.
//

import SwiftUI
import FilePicker

struct ExtractView: View {
    @StateObject private var errorViewModel = ErrorViewModel()

    @ObservedObject var extractionModel: ExtractionModel
    @ObservedObject var progressPublisher: ProgressPublisher
   
    @EnvironmentObject var settings: SettingsContainer
    
    @State var showMoreQuickSettings = false
    @State var emptyExportDestination = false
    
    var body: some View {
        VStack {
            //Drag And Drop File Zone
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    //Text Prompt To Drop Final Cut Pro XML File
                    Label("Drag and Drop FCP XML", systemImage: "cursorarrow.rays")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.linearGradient(Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                    
                    Text("OR")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.top, 8)
                        .padding(.bottom, 18)
                    
                    FilePicker(types: [.fcpxml, .fcpxmld], allowMultiple: false) { urls in
                        if !urls.isEmpty {
                            Task {
                                await extractionModel.performExtraction(urls[0])
                            }
                        }
                    } label: {
                        Label("Choose File", systemImage: "folder")
                            .font(.system(size: 18, weight: .bold))
                            .padding(8)
                            .frame(width: 150, height: 36)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
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
            
            HStack {
                VStack(alignment: .leading) {
                    //Divide Drag And Drop Zone From Quick Actions
                    Divider()
                    
                    //Quick Settings Title
                    Text("Quick Settings")
                        .font(.title2)
                        .bold()
                    
                    // Always visible quick settings
                    HStack {
                        Text("Export Destination: ")
                        
                        FolderPicker(
                            url: $settings.store.exportFolderURL,
                            title: "Choose…"
                        )
                        .onChange(of: settings.store.exportFolderURL) { newURL in
                            if let exportURL = settings.store.exportFolderURL {
                                withAnimation {
                                    emptyExportDestination = exportURL.absoluteString.isEmpty
                                }
                            }
                        }
                        .onAppear {
                            if let exportURL = settings.store.exportFolderURL {
                                print(exportURL.absoluteString)
                                emptyExportDestination = exportURL.absoluteString.isEmpty
                            } else {
                                emptyExportDestination = true
                            }
                        }
                        
                        if emptyExportDestination {
                            Text("Please select an export destination!")
                                .foregroundStyle(.red)
                        }
                        
                        Divider()
                            .padding(.horizontal, 3)
                            .frame(maxHeight: 16)
                        
                        ExportFormatPicker()
                            .frame(maxWidth: 300)
                    }
                    
                    HStack {
                        Button {
                            withAnimation {
                                showMoreQuickSettings = !showMoreQuickSettings
                            }
                        } label: {
                            Label(
                                showMoreQuickSettings ? "Show Less" : "Show More",
                                systemImage: showMoreQuickSettings ? "chevron.down" : "chevron.up"
                            )
                            .font(.system(.body, weight: .light))
                            .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        
                        if showMoreQuickSettings {
                            // Divider line
                            Rectangle()
                                .fill(.tertiary)
                                .frame(height: 1)
                        }
                    }
                    
                    // Hidden quick settings
                    if showMoreQuickSettings {
                        HStack {
                            Toggle("Upload", isOn: $settings.store.isUploadEnabled)
                                .toggleStyle(CheckboxToggleStyle())
                            
                            ExcludedRolesPicker()
                            
                            ImageModePicker()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
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
    @StateObject var settings = SettingsContainer()

    @StateObject var progressPublisher = ProgressPublisher(
        progress: Progress(totalUnitCount: 100)
    )

    @StateObject var extractionModel = ExtractionModel(
        settings: settings,
        progressPublisher: progressPublisher
    )

    return ExtractView(
        extractionModel: extractionModel,
        progressPublisher: progressPublisher
    )
    .environmentObject(settings)
}
