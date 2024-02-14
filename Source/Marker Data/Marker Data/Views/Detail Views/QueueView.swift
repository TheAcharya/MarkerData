//
//  QueueView.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import SwiftUI

struct QueueView: View {
    @ObservedObject var queueModel: QueueModel
    
    @State var showScanAlert = false
    
    @AppStorage("deleteFolderAfterUpload") var deleteAfterUpload = false
    
    var body: some View {
        VStack {
            tableView
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 8)
            
            actionsAndSettingsView
        }
        .padding()
        .alert("Failed to scan export folder", isPresented: $showScanAlert) {}
        .task {
            do {
                try await queueModel.scanExportFolder()
            } catch {
                showScanAlert = true
            }
        }
    }
    
    var tableView: some View {
        Table(queueModel.queueInstances) {
            TableColumn("Name", value: \.name)
            TableColumn("Date", value: \.creationDateFormatted)
            TableColumn("Profile", value: \.extractInfo.profile.rawValue)
            TableColumn("Upload Destination") { record in
                UploadDestinationPickerView(queueInstance: record)
            }
            TableColumn("Status") { queueInstance in
                QueueStatusView(queueInstance: queueInstance)
            }
        }
    }
    
    var actionsAndSettingsView: some View {
        HStack {
            Button {
                Task {
                    try await queueModel.upload(deleteFolder: deleteAfterUpload)
                }
            } label: {
                Label("Start Upload", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
//            .disabled(queueModel.queueInstances.allSatisfy { $0.uploadDestination.isNone } )
            
            Divider()
                .frame(maxHeight: 20)
                .padding(.horizontal, 5)
            
            Toggle("Delete Folders After Upload", isOn: $deleteAfterUpload)
            
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
    @StateObject var databaseManager = DatabaseManager()
    
    @StateObject var queueModel = QueueModel(
        settings: settings,
        databaseManager: databaseManager
    )
    
    return QueueView(queueModel: queueModel)
}
