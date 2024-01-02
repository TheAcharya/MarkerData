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
    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        VStack {
            // Drag And Drop File Zone
            ZStack {
                titleAndFileOpenView
                    // Disable and dim while extracting
                    .padding(.bottom, 60)
                    .disabled(extractionModel.extractionInProgress)
                    .grayscale(extractionModel.extractionInProgress ? 0.8 : 0)
                
                VStack {
                    Spacer()
                    
                    // Install share destination card
                    InstallShareDestinationCard()
                    
                    // Progress
                    if extractionModel.showProgress {
                        ExtractionAndUploadProgressView(extractionModel: extractionModel)
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
        .alert("Failed to exract completely", isPresented: $extractionModel.extractionProgress.showAlert) {} message: {
            Text(extractionModel.extractionProgress.alertMessage)
        }
        .alert("Failed to upload completely", isPresented: $extractionModel.uploadProgress.showAlert) {} message: {
            Text(extractionModel.uploadProgress.alertMessage)
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
    
    struct ExtractionAndUploadProgressView: View {
        @EnvironmentObject var databaseManager: DatabaseManager
        @Environment(\.openWindow) var openWindow
        
        @ObservedObject var extractionModel: ExtractionModel
        @State var showAllCompleteFooter = false
    
        var body: some View {
            VStack(alignment: .leading) {
                // Extraction progress
                ExportProgressView(progressModel: extractionModel.extractionProgress)
                    .padding(.bottom, 5)
                
                // Upload progress
                if databaseManager.selectedDatabaseProfile != nil {
                    ExportProgressView(progressModel: extractionModel.uploadProgress)
                }
                
                // All complete footer
                if showAllCompleteFooter {
                    Divider()
                    
                    HStack {
                        // Show exit status
                        Group {
                            if extractionModel.exportResult == .success {
                                Label("All Complete", systemImage: "checkmark.circle")
                                    .foregroundStyle(.green)
                            } else {
                                Label("Error", systemImage: "exclamationmark.circle")
                                    .foregroundStyle(.yellow)
                            }
                        }
                        .font(.title3)
                        
                        // Show failed tasks button
                        if extractionModel.exportResult == .failed {
                            Button {
                                openWindow(value: extractionModel.failedTasks)
                            } label: {
                                Label("Show failed tasks", systemImage: "info.circle")
                            }
                        }
                        
                        Spacer()
                        
                        // Open in Finder button
                        Button {
                            if let url = extractionModel.completedOutputFolder {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Label("Show in Finder", systemImage: "folder")
                        }
                        
                        // Close button
                        Button {
                            Task {
                                await MainActor.run {
                                    withAnimation {
                                        showAllCompleteFooter = false
                                        extractionModel.showProgress = false
                                    }
                                }
                            }
                        } label: {
                            Label("Close", systemImage: "xmark")
                        }
                    }
                    .padding(.top, 5)
                }
            }
            .padding()
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onChange(of: extractionModel.exportResult) { result in
                if result != .none {
                    withAnimation(.easeOut(duration: 1)) {
                        showAllCompleteFooter = true
                    }
                }
            }
        }
    }
    
    struct ExportProgressView: View {
        @ObservedObject var progressModel: ProgressViewModel
        
        var percentageText: String {
            let percent = Int(progressModel.progress.fractionCompleted * 100)
            
            if percent == 0 {
                return "-"
            }
            
            return "\(percent)%"
        }
        
        var body: some View {
            HStack(alignment: .bottom) {
                // Progress bar
                ProgressView(value: progressModel.progress.fractionCompleted) {
                    if progressModel.icon.isEmpty {
                        Text(progressModel.message)
                    } else {
                        Label(progressModel.message, systemImage: progressModel.icon)
                    }
                }
                .font(.system(size: 18, weight: .bold))
                
                Text(percentageText)
                    .frame(width: 50)
                    .font(.system(size: 18, weight: .light))
                
                Spacer()
            }
        }
    }
    
    struct QuickSettingsView: View {
        @EnvironmentObject var settings: SettingsContainer
        @EnvironmentObject var databaseManager: DatabaseManager
        
        @State var emptyExportDestination = false
        
        var body: some View {
            VStack(alignment: .leading) {
                // Divide Drag And Drop Zone From Quick Actions
                Divider()
                
                // Quick Settings Title
                Text("Quick Settings")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, -1)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        // Export destination picker
                        VStack(alignment: .leading) {
                            Text("Export Folder: ")
                            
                            FolderPicker(
                                url: $settings.store.exportFolderURL,
                                title: "Choose…"
                            )
                        }
                        
                        if emptyExportDestination {
                            Text("Please select an export destination!")
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(minWidth: 250, alignment: .leading)
                    // Check for empty export destination
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
                    
                    Divider()
                        .padding(.horizontal, 3)
                        .frame(maxHeight: 42)
                    
                    // Export profile picker
                    VStack(alignment: .leading) {
                        ExportProfilePicker()
                        
                        Text("Save data locally or upload to database")
                            .fontWeight(.thin)
                    }
                    .frame(minWidth: 300, alignment: .leading)
                }
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
    @StateObject var databaseManager = DatabaseManager()

    @StateObject var extractionModel = ExtractionModel(
        settings: settings,
        databaseManager: databaseManager
    )

    return ExtractView(extractionModel: extractionModel)
        .frame(width: WindowSize.detailWidth, height: WindowSize.fullHeight)
        .environmentObject(settings)
        .environmentObject(databaseManager)
        .preferredColorScheme(.dark)
}
