//
//  WorkflowExtensionView.swift
//  Marker Data
//
//  Created by Milán Várady on 24/01/2024.
//

import SwiftUI

struct WorkflowExtensionView: View {
    @State var droppedData = "no data"
    
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
            
            Text(droppedData)
            
            Spacer()
        }
        .frame(width: 600, height: 400)
        .padding()
    }
    
    var titleHeaderView: some View {
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
    
    var extractTabView: some View {
        VStack {
            Spacer()
            
            Text("Drag & Drop FCP Project Here")
            
            Spacer()
            
            HStack {
                Text("Profile selector")
                
                Spacer()
            }
        }
        .onDrop(of: ["com.apple.finalcutpro.xml.v1-10", "com.apple.finalcutpro.xml.v1-9", "com.apple.finalcutpro.xml"], isTargeted: nil) { providers -> Bool in
            for provider in providers {
                provider.loadDataRepresentation(forTypeIdentifier: "com.apple.finalcutpro.xml") { data, error in
                    if let data = data, let xmlString = String(data: data, encoding: .utf8) {
                        
                        droppedData = xmlString
                        print(xmlString)
                        
                    }
                }
            }
            return true
        }
    }
    
    var rolesTabView: some View {
        Text("Roles")
    }
}

#Preview {
    WorkflowExtensionView()
        .preferredColorScheme(.dark)
}
