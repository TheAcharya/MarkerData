//
//  DropboxSetupView.swift
//  Marker Data
//
//  Created by Milán Várady on 08/02/2024.
//

import SwiftUI

struct DropboxSetupView: View {
    @State var appKey = ""
    @State var authCode = ""
    
    @StateObject var dropboxSetupModel = DropboxSetupModel()
    
    @State var showAppKeyError = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Dropbox setup")
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
                    Button("Register") {
                        Task {
                            do {
                                try await  dropboxSetupModel.saveAndRegisterAppKey(appKey)
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
                case .success:
                    Label("Success", systemImage: "checkmark.circle")
                        .foregroundColor(.green)
                }
            }
            .alert("Failed to register app key", isPresented: $showAppKeyError) {}
            
            HStack {
                Text("Dropbox Authorization URL:")
                
                Text("Please open the link and click \"Allow\" to obtain auth code.")
                    .fontWeight(.light)
                
                Link("Auth link", destination: dropboxSetupModel.authURL ?? URL(string: "https://example.com/")!)
                    .disabled(dropboxSetupModel.authURL == nil)
            }
            
            HStack {
                PlatformInfoTextField(
                    title: "Dropbox Authorization Code",
                    prompt: "Paste auth code",
                    text: $authCode,
                    isRequired: true,
                    secureField: false
                )
                
                Button("Save") {
                    
                }
                .disabled(authCode.isEmpty)
            }
            
            Text(dropboxSetupModel.setupComplete ? "Dropbox is ready" : "Dropbox setup incomplete")
                .foregroundColor(dropboxSetupModel.setupComplete ? .green : .red)
        }
    }
}

#Preview {
    DropboxSetupView()
        .preferredColorScheme(.dark)
        .padding()
}
