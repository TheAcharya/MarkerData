//
//  ExportDestinationPicker.swift
//  Marker Data
//
//  Created by Milán Várady on 05/01/2024.
//

import SwiftUI
import FilePicker

struct ExportDestinationPicker: View {
    @EnvironmentObject var settings: SettingsContainer
    
    @State var exportDestinationText = ""
    @State var showWarning = false
    
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
                .onAppear {
                    updateExportDestinationText()
                }
            
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
                    updateExportDestinationText()
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
                updateExportDestinationText()
            } label: {
                Label("Clear Path", systemImage: "trash")
            }
            .labelStyle(.titleAndIcon)
        }
    }
    
    /// Updates the export destination url text and checks if the folder exists
    private func updateExportDestinationText() {
        guard let exportDestination = self.settings.store.exportFolderURL else {
            self.exportDestinationText = "Please select!"
            self.showWarning = true
            return
        }
        
        // Check if file exists
        if !exportDestination.fileExists {
            self.exportDestinationText = "Missing Folder!"
            self.showWarning = true
            return
        }
        
        self.exportDestinationText = exportDestination.lastPathComponent
        self.showWarning = false
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    
    settings.store.exportFolderURL = URL(string: "/Users/user/marker_data")
    
    return ExportDestinationPicker()
        .preferredColorScheme(.dark)
        .frame(width: 400, height: 100)
        .environmentObject(settings)
}