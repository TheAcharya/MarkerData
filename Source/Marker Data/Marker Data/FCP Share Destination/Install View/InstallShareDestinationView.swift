//
//  InstallShareDestinationView.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import SwiftUI

struct InstallShareDestinationView: View {
    @AppStorage("showFCPShareDestinationCard") var showSelf = true
    
    @State var showFailAlert = false
    @State var installDone = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Install Final Cut Pro Share Extension")
                    .bold()
                
                Text("Simplify your workflow by adding Marker Data to FCP share menu")
                    .fontWeight(.light)
            }
            
            Spacer()
            
            if installDone {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .imageScale(.large)
                    
                    Text("Installed")
                }
            } else {
                Button {
                    Task {
                        do {
                            try await ShareDestinationInstaller.install()
                            withAnimation {
                                installDone = true
                            }
                        } catch {
                            showFailAlert = true
                        }
                    }
                } label: {
                    Label("Install", systemImage: "square.and.arrow.down.fill")
                }
            }
            
            Button {
                withAnimation {
                    showSelf = false
                }
            } label: {
                Label("Don't show again", systemImage: "xmark")
            }
            .labelStyle(.iconOnly)
            .help("Don't show again")
        }
        .padding()
        .background(.linearGradient(colors: [.black, Color.darkPurple], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .alert("Failed to install Share Destination", isPresented: $showFailAlert) {}
    }
}

#Preview {
    VStack {
        InstallShareDestinationView()
    }
    .frame(width: 600, height: 300)
}
