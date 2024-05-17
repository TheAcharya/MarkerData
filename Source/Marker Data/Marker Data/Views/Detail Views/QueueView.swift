//
//  QueueView.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import SwiftUI

struct QueueView: View {
    @ObservedObject var queueModel: QueueModel

    @State var scanFailed = false
    @State var sortOrder = [KeyPathComparator(\QueueInstance.extractInfo.creationDate)]

    var body: some View {
        VStack {
            ZStack {
                tableView
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 8)
            }

            actionsAndSettingsView
        }
        .padding()
        .overlayHelpButton(url: Links.queueHelpURL)
        .task {
            do {
                try await queueModel.scanExportFolder()
            } catch {
                scanFailed = true
            }

            await queueModel.filterMissing()
        }
    }
    
    var tableView: some View {
        Table(queueModel.queueInstances, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name) { queueInstance in
                Text(queueInstance.name)
                    .help(queueInstance.name)
            }
            .width(ideal: 110)

            TableColumn("Date", value: \.extractInfo.creationDate) { queueInstance in
                Text(queueInstance.creationDateFormatted)
                    .help(queueInstance.creationDateFormatted)
            }
            .width(ideal: 100)

            TableColumn("Profile", value: \.extractInfo.profile.rawValue) { queueInstance in
                Text(queueInstance.extractInfo.profile.rawValue)
                    .help(queueInstance.extractInfo.profile.rawValue)
            }
            .width(ideal: 25)

            TableColumn("Upload Destination") { queueInstance in
                UploadDestinationPickerView(queueInstance: queueInstance)
                    .disabled(queueModel.uploadInProgress)
            }
            .width(ideal: 120)

            TableColumn("Status") { queueInstance in
                QueueStatusView(queueInstance: queueInstance)
            }
            .width(ideal: 60)
        }
        .onChange(of: sortOrder) { newOrder in
            queueModel.queueInstances.sort(using: newOrder)
        }
        .onDrop(of: [.fileURL], delegate: queueModel)
        .contextMenu {
            Button {
                queueModel.clear()
            } label: {
                Label("Clear", systemImage: "trash")
            }
        }
    }
    
    var actionsAndSettingsView: some View {
        HStack {
            // Start upload button
            Button {
                Task {
                    try await queueModel.upload()
                }
            } label: {
                Label("Start Upload", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .disabled(queueModel.uploadInProgress || queueModel.queueInstances.isEmpty)


            Button {
                queueModel.cancelUpload()
            } label: {
                Label("Stop", systemImage: "stop.circle")
                    .foregroundColor(queueModel.uploadInProgress ? Color.red : .secondary)
            }
            .disabled(!queueModel.uploadInProgress)

            // Load from Export Destination button
            Button {
                queueModel.automaticScanEnabled = true

                Task {
                    do {
                        try await queueModel.scanExportFolder()
                    } catch {
                        scanFailed = true
                    }
                }
            } label: {
                Label("Load from Export Destination", systemImage: "arrow.clockwise")
            }
            .disabled(queueModel.uploadInProgress)

            Divider()
                .frame(maxHeight: 20)
                .padding(.horizontal, 5)
            
            // Delete folders toggle
            Toggle("Delete Folders After Upload", isOn: $queueModel.deleteFolderAfterUpload)
            
            Spacer()
            

        }
    }
    
    struct UploadDestinationPickerView: View {
        @ObservedObject var queueInstance: QueueInstance
        
        var body: some View {
            Picker("", selection: $queueInstance.uploadDestination) {
                Text("No Upload")
                    .tag(nil as DatabaseProfileModel?)
                
                ForEach(queueInstance.availableDatabaseProfiles) { profile in
                    Text(profile.name)
                        .tag(profile as DatabaseProfileModel?)
                }
            }
            .labelsHidden()
        }
    }
    
    struct QueueStatusView: View {
        @ObservedObject var queueInstance: QueueInstance
        
        var body: some View {
            switch queueInstance.status {
            case .idle:
                HStack {
                    Spacer()
                    Text("-")
                    Spacer()
                }
            case .uploading:
                UploadProgressView(progressModel: queueInstance.uploader.uploadProgress)
            case .success:
                Label("Uploaded", systemImage: "checkmark.circle")
                    .foregroundStyle(Color.green)
            case .failed:
                Label("Failed", systemImage: "xmark.circle")
                    .foregroundStyle(Color.red)
            }
        }
    }
    
    struct UploadProgressView: View {
        @ObservedObject var progressModel: ProgressViewModel
        
        var body: some View {
            ProgressView(value: progressModel.progress.fractionCompleted)
        }
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var databaseManager = DatabaseManager(settings: settings)
    
    @StateObject var queueModel = QueueModel(
        settings: settings,
        databaseManager: databaseManager
    )
    
    return QueueView(queueModel: queueModel)
}
