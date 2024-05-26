//
//  WorkflowExtensionView.swift
//  Marker Data
//
//  Created by Milán Várady on 24/01/2024.
//

import SwiftUI

struct WorkflowExtensionView: View {
    @State var errorMessage = ""
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            titleHeaderView
                .padding(.bottom, 5)
            
            Divider()
            
            TabView {
                extractTabView
                    .tabItem {
                        Label("Extract", systemImage: "gearshape.2")
                    }
                
                RolesSettingsView()
                    .padding(8)
                    .tabItem {
                        Label("Roles", systemImage: "movieclapper")
                    }
            }
            .padding(.bottom)
            
            Spacer()
        }
        .frame(width: 600, height: 400)
        .padding()
        .overlay(alignment: .bottomTrailing) {
            HelpButton {
                self.openURL(URL(string: "https://markerdata.theacharya.co/user-guide/workflow-extension/")!)
            }
            .padding([.trailing, .bottom], 10)
        }
    }
    
    private var titleHeaderView: some View {
        HStack {
            Image("AppIconSingle")
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                Text("Marker Data")
                    .font(.title)
                
                Text("The avant-garde Marker extraction application crafted for Final Cut Pro")
            }
            
            Spacer()
        }
    }
    
    private var extractTabView: some View {
        VStack {
            Spacer()
            
            Text("Drag & Drop Final Cut Pro Project to Open Marker Data")
            
            if !self.errorMessage.isEmpty {
                Text("Failed to receive file: \(self.errorMessage)")
                    .foregroundColor(Color.red)
            }
            
            Spacer()
        }
        .onDrop(of: [.fcpxml], isTargeted: nil) { providers -> Bool in
            for provider in providers {
                _ = provider.loadDataRepresentation(for: .fcpxml) { data, error in
                    self.handleDrop(data: data)
                }
            }
            return true
        }
    }
    
    private var rolesTabView: some View {
        Text("Roles")
    }
    
    private func handleDrop(data: Data?) {
        do {
            // Reset error message
            self.errorMessage = ""
            
            // Create file in cache
            let url = URL.moviesDirectory
                .appendingPathComponent("Marker Data Cache", conformingTo: .folder)
                .appendingPathComponent("WorkflowExtensionExport.fcpxml", conformingTo: .fcpxml)
            
            try data?.write(to: url)
            
            // Open Marker Data
            let path = "/bin"
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.arguments = [path]
            
            NSWorkspace.shared.openApplication(at: URL.markerDataApp,
                                               configuration: configuration) { app, error in
                // Notify Marker Data that the file is available
                DistributedNotificationCenter.default().post(name: .workflowExtensionFileReceived, object: nil)
            }
        } catch {
            // Show error message
            self.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    WorkflowExtensionView()
        .preferredColorScheme(.dark)
}
