//
//  DropboxSetupView.swift
//  Marker Data
//
//  Created by Milán Várady on 08/02/2024.
//

import SwiftUI

struct DropboxSetupView: View {
    @State var appKey = ""
    
    @StateObject var dropboxSetupModel = DropboxSetupModel()
    
    @State var showAppKeyError = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dropbox")
                .font(.title2)
            
            HStack {
                PlatformInfoTextField(
                    title: "Dropbox App Key",
                    prompt: "App key",
                    text: $appKey,
                    isRequired: true,
                    secureField: false
                )
                .disabled(dropboxSetupModel.authRequestStatus != .notInitiated)
                
                switch dropboxSetupModel.authRequestStatus {
                case .notInitiated:
                    Button("Continue") {
                        Task {
                            do {
                                try await dropboxSetupModel.saveAppKeyAndLaunchTerminal(appKey)
                            } catch {
                                showAppKeyError = true
                                dropboxSetupModel.authRequestStatus = .notInitiated
                            }
                        }
                    }
                    .disabled(appKey.isEmpty)
                case .inProgress:
                    ProgressView()
                        .controlSize(.small)
                        .padding(.horizontal, 5)
                    
                    Button {
                        dropboxSetupModel.authRequestStatus = .notInitiated
                    } label: {
                        Label("Start Over", systemImage: "arrow.clockwise")
                    }
                case .success:
                    Label("Success", systemImage: "checkmark.circle")
                        .foregroundColor(.green)
                }
            }
            .alert("Failed to save app key", isPresented: $showAppKeyError) {}
            
            Text("Clicking **Continue** will launch the Terminal. Follow the on-screen instructions for the rest of the setup process.")
                .fontWeight(.thin)
            
            Link(destination: Links.dropboxAppConsole) {
                Label("Open Dropbox App Console", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .padding(.bottom)
            
            Text(dropboxSetupModel.setupComplete ? "Dropbox configured" : "Dropbox setup incomplete")
                .foregroundColor(dropboxSetupModel.setupComplete ? .green : .red)
        }
    }
}

#Preview {
    DropboxSetupView()
        .preferredColorScheme(.dark)
        .padding()
}
