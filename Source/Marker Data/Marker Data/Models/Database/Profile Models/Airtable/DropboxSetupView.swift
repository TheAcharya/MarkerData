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
    @State var validSetup = false
    
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
                
                Button("Save & Register") {
                    
                }
            }
            
            HStack {
                Text("Dropbox Authorization URL:")
                
                Text("Please open the link and click \"Allow\" to obtain auth code.")
                    .fontWeight(.light)
                
                Link("Auth link", destination: URL(string: "https://example.com/")!)
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
            }
            
            Text(validSetup ? "Dropbox is ready" : "Dropbox setup incomplete")
                .foregroundColor(validSetup ? .green : .red)
        }
    }
}

#Preview {
    DropboxSetupView()
        .preferredColorScheme(.dark)
        .padding()
}
