//
//  RolesSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 25/01/2024.
//

import SwiftUI
import MarkersExtractor

struct RolesSettingsView: View {
    @StateObject var rolesManager = RolesManager()

    var body: some View {
        VStack {
            ZStack {
                tableView

                if rolesManager.loadingInProgress {
                    ProgressView()
                } else if self.rolesManager.roles.isEmpty {
                    // If nil or empty
                    Text("Drag & Drop Final Cut Pro Project (or .FCPXMLD) to Retrive Roles Metadata")
                }
            }
            
            buttonsView
        }
        .onDrop(of: [.fcpxml, .fileURL], delegate: rolesManager)
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
}

#Preview {
    RolesSettingsView()
        .preferredColorScheme(.dark)
        .frame(width: 600, height: 400)
        .padding()
}
