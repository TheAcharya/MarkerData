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
                tableView
                
                // If nil or empty
                if self.rolesManager.roles.isEmpty {
                    Text("Drag & Drop Final Cut Pro Project (or .FCPXMLD) to Retrive Roles Metadata")
                }
            }
            
            buttonsView
        }
        .onDrop(of: [.fcpxml, .fileURL], isTargeted: nil) { providers -> Bool in
            for provider in providers {
                // Load FCPXML
                if provider.hasRepresentationConforming(toTypeIdentifier: "com.apple.finalcutpro.xml") {
                    _ = provider.loadDataRepresentation(for: .fcpxml) { data, error in
                        Task {
                            guard let dataUnwrapped = data else {
                                return
                            }
                            
                            if let extractedRoles = await getRoles(fcpxml: FCPXMLFile(fileContents: dataUnwrapped)) {
                                await self.rolesManager.setRoles(extractedRoles)
                            }
                        }
                    }
                }
                
                // Load FCPXMLD
                if provider.canLoadObject(ofClass: URL.self) {
                    // Load the file URL from the provider
                    let _ = provider.loadObject(ofClass: URL.self) { url, error in
                        Task {
                            guard let urlUnwrapped = url else {
                                return
                            }
                            
                            if !urlUnwrapped.conformsToType([.fcpxmld]) {
                                print("File doesn't conform to FCPXMLD")
                                return
                            }
                               
                            if let extractedRoles = await getRoles(fcpxml: try FCPXMLFile(at: urlUnwrapped)) {
                                 self.rolesManager.setRoles(extractedRoles)
                            }
                        }
                    }
                }
            }
            
            return true
        }
    }
    
    var tableView: some View {
        Table(self.rolesManager.roles) {
            TableColumn("Roles", value: \.displayName)
            
            TableColumn("Kind") { role in
                Text(role.role.roleType.rawValue.titleCased)
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
    }
    
    var buttonsView: some View {
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
            
            Divider()
                .frame(height: 20)
                .padding(.horizontal, 8)
            
            // Enable all button
            Button {
                self.rolesManager.enableAll()
            } label: {
                Label("Enable All", systemImage: "checklist.checked")
            }
            
            // Disable all button
            Button {
                self.rolesManager.disableAll()
            } label: {
                Label("Disable All", systemImage: "checklist.unchecked")
            }
            
            Spacer()
        }
    }
    
    func getRoles(fcpxml: FCPXMLFile) async -> [RoleModel]? {
        do {
            let rolesExtractor = RolesExtractor(fcpxml: fcpxml)
            
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
