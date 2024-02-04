//
//  ExtractView.swift
//  Marker Data
//
//  Created by Milán Várady on 30/09/2023.
//

import SwiftUI
import FilePicker

public struct ExtractView: View {
    @ObservedObject var extractionModel: ExtractionModel
    @EnvironmentObject var settings: SettingsContainer
    
    @Environment(\.openWindow) var openWindow
    
    @AppStorage("showFCPShareDestinationCard") var showInstallShareDestination = true
    
    public var body: some View {
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
                    if showInstallShareDestination {
                        InstallShareDestinationView()
                    }
                    
                    // Progress
                    if extractionModel.showProgressUI {
                        ExtractionAndUploadProgressView(
                            settingsStore: self.settings.store,
                            extractionModel: extractionModel
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, -12)
            }
            .padding(.vertical)
            // Handle file drop and perform extraction
            .onDrop(
                of: [.fileURL],
                delegate: extractionModel
            )
            
            // Quick Settings
            QuickSettingsView()
        }
        .alert("Failed to exract completely", isPresented: $extractionModel.extractionProgress.showAlert) {
            Button("Show Error Details") {
                openWindow(value: extractionModel.failedTasks)
            }
            
            Button("Close", role: .cancel) {}
        } message: {
            Text(extractionModel.extractionProgress.alertMessage)
        }
        .alert("Failed to upload completely", isPresented: $extractionModel.uploadProgress.showAlert) {
            Button("Show Error Details") {
                openWindow(value: extractionModel.failedTasks)
            }
            
            Button("Close", role: .cancel) {}
        } message: {
            Text(extractionModel.uploadProgress.alertMessage)
        }
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
        @ObservedObject var settingsStore: SettingsStore
        @EnvironmentObject var databaseManager: DatabaseManager
        @Environment(\.openWindow) var openWindow
        
        @ObservedObject var extractionModel: ExtractionModel
        @State var showAllCompleteFooter = false
    
        var body: some View {
            VStack(alignment: .leading) {
                // External file
                if extractionModel.externalFileRecieved {
                    externalFilePopup
                } else {
                    // Extraction progress
                    ExportProgressView(progressModel: extractionModel.extractionProgress)
                        .padding(.bottom, 5)
                    
                    // Upload progress
                    if UnifiedExportProfile.load()?.exportProfileType == .extractAndUpload {
                        ExportProgressView(progressModel: extractionModel.uploadProgress)
                    }
                }
                
                // All complete footer
                if showAllCompleteFooter {
                    Divider()
                    
                    allCompleteFooter
                    .padding(.top, 5)
                }
            }
            .padding()
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .onAppear {
                if extractionModel.exportResult != .none {
                    showAllCompleteFooter = true
                }
            }
            .onChange(of: extractionModel.exportResult) { result in
                withAnimation(.easeOut(duration: 1)) {
                    showAllCompleteFooter = result != .none
                }
            }
        }
        
        var externalFilePopup: some View {
            HStack {
                PulsingIcon(
                    icon: "folder.circle.fill",
                    iconSize: 36
                )
                
                VStack(alignment: .leading) {
                    Text("External File Recieved")
                        .font(.title2)
                    
                    Text("Select Export Folder to contiue.")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Start extraction button
                Button {
                    withAnimation {
                        extractionModel.processExternalFile()
                    }
                } label: {
                    Label("Extract", systemImage: "gearshape.2")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!(self.settingsStore.exportFolderURL?.fileExists ?? false))
                
                Button("Cancel") {
                    withAnimation {
                        extractionModel.cancelExternalFile()
                    }
                }
            }
        }
        
        /// Footer shown when all extractions are complete
        var allCompleteFooter: some View {
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
                        Label("Show Error Details", systemImage: "info.circle")
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
                    withAnimation {
                        self.showAllCompleteFooter = false
                        extractionModel.showProgressUI = false
                    }
                    
                    Task {
                        await extractionModel.clearProgress()
                    }
                } label: {
                    Label("Close", systemImage: "xmark")
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
        
        @State var showHelp = false
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        // Export destination picker
                        VStack(alignment: .leading) {
                            Text("Export Folder")
                                .bold()
                            
                            ExportDestinationPicker()
                        }
                    }
                    .frame(minWidth: 300, alignment: .leading)
                    
                    Divider()
                        .padding(.horizontal, 3)
                        .frame(maxHeight: 60)
                    
                    // Export profile picker
                    VStack(alignment: .leading) {
                        Text("Export Profile")
                            .bold()
                        
                        ExportProfilePicker()
                            .labelsHidden()
                        
                        HStack {
                            Text("Save data locally or upload to database")
                                .fontWeight(.thin)
                            
                            HelpButton {
                                showHelp = true
                            }
                            .scaleEffect(0.8)
                            .popover(isPresented: $showHelp) {
                                Text("Select an export profile from the **No Upload** section to save the file locally only. Later, upload extracted files to a database according to the export profile from the **Recent Extractions** panel. Or select a database profile to upload immediately.")
                                    .frame(maxWidth: 300, minHeight: 100)
                                    .padding(10)
                            }
                        }
                    }
                    .frame(minWidth: 300, alignment: .leading)
                }
            }
            .padding()
            .background(.black)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var databaseManager = DatabaseManager()
    @StateObject var configurationsModel = ConfigurationsModel()

    @StateObject var extractionModel = ExtractionModel(
        settings: settings,
        databaseManager: databaseManager
    )

    return ExtractView(extractionModel: extractionModel)
        .frame(width: WindowSize.detailWidth, height: WindowSize.fullHeight)
        .environmentObject(settings)
        .environmentObject(databaseManager)
        .environmentObject(configurationsModel)
        .preferredColorScheme(.dark)
}
