//
//  InstallShareDestinationView.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import SwiftUI

struct InstallShareDestinationView: View {
    @AppStorage("showFCPShareDestinationCard") var showSelf = true
    
    private enum InstallStage {
        case notInstalled
        case inProgress
        case installed
    }
    
    @State private var installStage: InstallStage = .notInstalled
    
    @State private var showFailAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Install Final Cut Pro Share Extension")
                    .bold()
                
                Text("Enhance your workflow by adding Marker Data to Final Cut Pro's Share menu")
                    .fontWeight(.light)
            }
            
            Spacer()
            
            switch self.installStage {
            case .notInstalled:
                installButton
            case .inProgress:
                ProgressView()
                    .imageScale(.small)
                    .padding(.trailing)
            case .installed:
                installedText
            }
            
            closeButton
                .disabled(self.installStage == .inProgress)
                .labelStyle(.iconOnly)
                .help("Don't show again")
        }
        .padding()
        .background(.linearGradient(colors: [.black, .darkPurple], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .alert("Failed to install Share Destination", isPresented: $showFailAlert) {}
    }
    
    var installButton: some View {
        Button {
            Task {
                do {
                    withAnimation {
                        self.installStage = .inProgress
                    }
                    
                    try await ShareDestinationInstaller.install()
                    
                    withAnimation {
                        self.installStage = .installed
                    }
                } catch {
                    showFailAlert = true
                }
            }
        } label: {
            Label("Install", systemImage: "square.and.arrow.down.fill")
        }
    }
    
    var installedText: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .imageScale(.large)
            
            Text("Installed")
        }
    }
    
    var closeButton: some View {
        Button {
            withAnimation {
                showSelf = false
            }
        } label: {
            Label("Don't show again", systemImage: "xmark")
        }
    }
}

#Preview {
    VStack {
        InstallShareDestinationView()
    }
    .frame(width: 600, height: 300)
}
