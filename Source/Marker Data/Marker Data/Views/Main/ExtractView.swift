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
    
    var body: some View {
        VStack {
            // Drag And Drop File Zone
            ZStack {
                titleAndFileOpenView
                    // Disable and dim while extracting
                    .padding(.bottom, 60)
                    .disabled(extractionModel.extractionInProgresss)
                    .grayscale(extractionModel.extractionInProgresss ? 0.8 : 0)
                
                VStack {
                    Spacer()
                    
                    // Install share destination card
                    InstallShareDestinationCard()
                    
                    // Progress
                    if progressPublisher.showProgress {
                        extractionProgressView
                    }
                }
            }
            .padding(.vertical)
            // Handle file drop and perform extraction
            .onDrop(
                of: ExtractionModel.supportedContentTypes,
                delegate: extractionModel
            )
            
            // Quick Settings
            QuickSettingsView()
        }
        .padding()
        .overlay(UserAlertView(title: "Error", onDismiss: {
            // Perform any action you want when the user dismisses the alert.
        })
        .alert("Failed to exract completely", isPresented: $progressPublisher.showAlert) {} message: {
            Text(progressPublisher.alertMessage)
        }
        .environmentObject(extractionModel.errorViewModel))
    }
    
    var titleAndFileOpenView: some View {
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
                
                FilePicker(types: [.fcpxml, .fcpxmld], allowMultiple: true) { urls in
                    if !urls.isEmpty {
                        Task {
                            await extractionModel.performExtraction(urls)
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
    }
    
    var extractionProgressView: some View {
        HStack(alignment: .bottom) {
            ProgressView(value: progressPublisher.progress.fractionCompleted, total: 1) {
                if progressPublisher.icon.isEmpty {
                    Text(progressPublisher.message)
                } else {
                    Label(progressPublisher.message, systemImage: progressPublisher.icon)
                }
            }
            .font(.system(size: 18, weight: .bold))
            
            HStack {
                if extractionModel.completedOutputFolder != nil {
                    // Open in Finder button
                    Button {
                        if let url = extractionModel.completedOutputFolder {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label("Show in Finder", systemImage: "folder")
                    }
                    
                    Button {
                        withAnimation {
                            progressPublisher.showProgress = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                } else {
                    // Show progress
                    HStack {
                    let percentage: Int = Int(progressPublisher.progress.fractionCompleted * 100)
                        Text("\(percentage)%")
                            .font(.system(size: 18, weight: .light))
                        
                        Spacer()
                    }
                }
            }
            .frame(width: 180)
        }
        .padding()
        .frame(height: 50)
        .background(.quinary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    struct QuickSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        
        @State var showMoreQuickSettings = false
        @State var emptyExportDestination = false
        
        var body: some View {
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
                            
                            ImageModePicker()
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
    
    struct InstallShareDestinationCard: View {
        @AppStorage("showFCPShareDestinationCard") var showSelf = true
        
        var body: some View {
            if showSelf {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Install Final Cut Pro Share Extension")
                            .bold()
                        
                        Text("Simplify your workflow by adding Marker Data to FCP share menu")
                            .fontWeight(.light)
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Label("Install", systemImage: "square.and.arrow.down.fill")
                    }
                    
                    Button {
                        withAnimation {
                            showSelf = false
                        }
                    } label: {
                        Label("Don't show again", systemImage: "xmark")
                    }
                    .labelStyle(.iconOnly)
                    .help("Don't show again")
                }
                .padding()
                .background(.linearGradient(colors: [.black, Color.darkPurple], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var progressPublisher = ProgressPublisher()
    @StateObject var databaseManager = DatabaseManager()

    @StateObject var extractionModel = ExtractionModel(
        settings: settings,
        progressPublisher: progressPublisher,
        databaseManager: databaseManager
    )

    return ExtractView(
        extractionModel: extractionModel,
        progressPublisher: progressPublisher
    )
    .environmentObject(settings)
}
