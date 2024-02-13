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
            Text(String(describing: queueModel.records))
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
