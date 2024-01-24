//
//  WorkflowExtensionView.swift
//  Marker Data
//
//  Created by Milán Várady on 24/01/2024.
//

import SwiftUI

struct WorkflowExtensionView: View {
    @State var errorMessage = ""
    
    var body: some View {
        VStack {
            titleHeaderView
            
            Divider()
            
            TabView {
                extractTabView
                    .tabItem {
                        Label("Extract", systemImage: "gearshape.2")
                    }
                
                rolesTabView
                    .tabItem {
                        Label("Roles", systemImage: "movieclapper")
                    }
            }
            
            Spacer()
        }
        .frame(width: 600, height: 400)
        .padding()
    }
    
    private var titleHeaderView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Marker Data")
                    .font(.title)
                
                Text("The avant-garde Marker extraction application crafted for Final Cut Pro")
            }
            
            Spacer()
            
            Image("AppIconSingle")
                .resizable()
                .frame(width: 50, height: 50)
        }
    }
    
    private var extractTabView: some View {
        VStack {
            Spacer()
            
            Text("Drag & Drop FCP Project Here")
            
            if !self.errorMessage.isEmpty {
                Text("Failed to receive file: \(self.errorMessage)")
                    .foregroundColor(Color.red)
            }
            
            Spacer()
            
            HStack {
                Text("Profile selector")
                
                Spacer()
            }
        }
        .onDrop(of: ["com.apple.finalcutpro.xml.v1-10", "com.apple.finalcutpro.xml.v1-9", "com.apple.finalcutpro.xml"], isTargeted: nil) { providers -> Bool in
            for provider in providers {
                provider.loadDataRepresentation(forTypeIdentifier: "com.apple.finalcutpro.xml") { data, error in
                    self.handleDrop(data: data)
                }
            }
            return true
        }
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
            
            openApp("Marker Data")
            
            // Notify Marker Data that the file is available
            DistributedNotificationCenter.default().post(name: Notification.Name("WorkflowExtensionFileReceived"), object: nil)
        } catch {
            // Show error message
            self.errorMessage = error.localizedDescription
        }
    }
    
    @discardableResult
    private func openApp(_ named: String) -> Bool {
        NSWorkspace.shared.launchApplication(named)
    }
    
    private var rolesTabView: some View {
        Text("Roles")
    }
}

#Preview {
    WorkflowExtensionView()
        .preferredColorScheme(.dark)
}
