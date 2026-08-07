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
    @State private var isDropTargeted = false
    @State private var sortOrder = [KeyPathComparator(\QueueInstance.creationDate, order: .reverse)]

    var body: some View {
        VStack {
            ZStack {
                tableView
                    .clipShape(.rect(cornerRadius: 8))

                if isDropTargeted, !queueModel.uploadInProgress {
                    DropTargetOverlay(
                        message: "Drop Extract Folders (Notion or Airtable) into Queue",
                        subtitle: nil,
                        systemImage: "folder.fill"
                    )
                }
            }
            .padding(.bottom, 8)
            .animation(.easeInOut(duration: 0.2), value: isDropTargeted)

            actionsAndSettingsView
        }
        .padding()
        .overlayHelpButton(url: Links.queueHelpURL)
        .onChange(of: queueModel.uploadInProgress) { _, uploading in
            if uploading {
                isDropTargeted = false
            }
        }
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

            TableColumn("Date", value: \.creationDate) { queueInstance in
                Text(queueInstance.creationDateFormatted)
                    .help(queueInstance.creationDateFormatted)
            }
            .width(ideal: 100)

            TableColumn("Profile", value: \.profile.rawValue) { queueInstance in
                Text(queueInstance.profile.rawValue)
                    .help(queueInstance.profile.rawValue)
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
        .onChange(of: sortOrder) {
            queueModel.queueInstances.sort(using: sortOrder)
        }
        .dropDestination(for: URL.self) { urls, _ in
            guard !queueModel.uploadInProgress else { return false }
            queueModel.performDrop(urls: urls)
            return true
        } isTargeted: { targeted in
            isDropTargeted = queueModel.uploadInProgress ? false : targeted
        }
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
                    .foregroundStyle(queueModel.uploadInProgress ? Color.red : .secondary)
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
    let settings = SettingsContainer()
    let databaseManager = DatabaseManager(settings: settings)
    let queueModel = QueueModel(
        settings: settings,
        databaseManager: databaseManager
    )

    return QueueView(queueModel: queueModel)
        .environmentObject(settings)
}
