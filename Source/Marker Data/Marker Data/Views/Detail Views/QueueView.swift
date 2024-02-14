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
    
    var body: some View {
        VStack {
            tableView
        }
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
        Table(queueModel.records) {
            TableColumn("Name", value: \.name)
            TableColumn("Date", value: \.creationDateFormatted)
            TableColumn("Profile", value: \.extractInfo.profile.rawValue)
            TableColumn("Upload Destination") { record in
                UploadDestinationPickerView(queueInstance: record)
            }
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
