//
//  RolesSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 25/01/2024.
//

import SwiftUI
import MarkersExtractor
import DAWFileKit
import UniformTypeIdentifiers

struct RolesSettingsView: View {
    @StateObject var rolesManager = RolesManager()
    
    var body: some View {
        VStack {
            ZStack {
                Table(self.rolesManager.roles) {
                    TableColumn("Roles", value: \.role.role)
                    
                    TableColumn("Kind") { role in
                        Text(role.role.collapsingSubRole().role)
                    }
                    
                    TableColumn("Enabled") { role in
                        Toggle("", isOn: Binding<Bool>(
                            get: {
                                return role.enabled
                            },
                            set: {
                                if let index = self.rolesManager.roles.firstIndex(where: { $0.id == role.id }) {
                                    self.rolesManager.roles[index].enabled = $0
                                    
                                    do {
                                        try self.rolesManager.save()
                                    } catch {
                                        print("Failed to save roles to disk")
                                    }
                                }
                            }
                        ))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // If nil or empty
                if self.rolesManager.roles.isEmpty {
                    Text("Drag & Drop FCP Timeline to retrive Roles Metadata")
                }
            }
            
            HStack {
                // Clear button
                Button {
                    self.rolesManager.setRoles([])
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                
                // Refresh Button
                Button {
                    self.rolesManager.refresh()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                
                Spacer()
            }
        }
        .onDrop(of: [.fcpxml, .fcpxmld], isTargeted: nil) { providers -> Bool in
            for provider in providers {
                _ = provider.loadDataRepresentation(for: .fcpxml) { data, error in
                    Task {
                        if let extractedRoles = await handleData(data) {
                            await self.rolesManager.setRoles(extractedRoles)
                        }
                    }
                }
            }
            
            return true
        }
    }
    
    func handleData(_ data: Data?) async -> [RoleModel]? {
        guard let data = data else {
            return nil
        }
        
        do {
            let rolesExtractor = RolesExtractor(fcpxml: FCPXMLFile(fileContents: data))
            
            let roles = try await rolesExtractor.extract()
            
            let roleModels = roles.map { RoleModel(role: $0, enabled: true) }
            
            return roleModels
        } catch {
            print("Failed to extract roles")
            return nil
        }
    }
}

#Preview {
    RolesSettingsView()
        .preferredColorScheme(.dark)
        .frame(width: 600, height: 400)
        .padding()
}
