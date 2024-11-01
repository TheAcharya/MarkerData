//
//  ExportDestinationPicker.swift
//  Marker Data
//
//  Created by Milán Várady on 05/01/2024.
//

import SwiftUI
import Combine
import FilePicker

struct ExportDestinationPicker: View {
    @EnvironmentObject var settings: SettingsContainer
    
    var exportDestinationText: String {
        guard let exportDestination = self.settings.store.exportFolderURL else {
            return "Please select!"
        }

        // Check if file exists
        if !exportDestination.fileExists {
            return "Missing Folder!"
        }

        return exportDestination.lastPathComponent
    }

    var showWarning: Bool {
        // Check if url is nil
        guard let url = settings.store.exportFolderURL else {
            return true
        }

        // Check if folder exists
        return !url.fileExists
    }

    @State var settingsUpdateCancallable: AnyCancellable? = nil
    @State var configurationUpdaterCancellable: AnyCancellable? = nil
    
    var body: some View {
        HStack {
            if showWarning {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(Color.red)
            }
            
            Text(exportDestinationText)
                .padding(.horizontal)
                .truncationMode(.head)
                .lineLimit(1)
                .foregroundStyle(showWarning ? Color.red : .primary)
            
            Spacer()
            
            // Choose file dialog
            Button {
                let dialog = NSOpenPanel();
                
                dialog.title = "Choose a folder";
                dialog.showsResizeIndicator = true;
                dialog.showsHiddenFiles = false;
                dialog.canChooseFiles = false;
                dialog.canChooseDirectories = true;
                
                if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                    guard let url = dialog.url else {
                        return
                    }
                    
                    settings.store.exportFolderURL = url
                }
            } label: {
                Image(systemName: "folder")
            }
        }
        .frame(maxWidth: 300)
        .padding(5)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .shadow(color: .white, radius: 1)
        .onDisappear {
            self.settingsUpdateCancallable?.cancel()
            self.configurationUpdaterCancellable?.cancel()
        }
        .contextMenu {
            // Full path
            Section("Full Path") {
                Text(settings.store.exportFolderURL?.path(percentEncoded: false) ?? "Empty Path")
                    .truncationMode(.head)
                    .frame(maxWidth: 250)
            }
            
            // Clear button
            Button {
                settings.store.exportFolderURL = nil
            } label: {
                Label("Clear Path", systemImage: "trash")
            }
            .labelStyle(.titleAndIcon)
        }
    }
}

#Preview {
    let settings = SettingsContainer()
    settings.store.exportFolderURL = URL(string: "/Users/user/marker_data")
    
    return ExportDestinationPicker()
        .preferredColorScheme(.dark)
        .frame(width: 400, height: 100)
        .environmentObject(settings)
}