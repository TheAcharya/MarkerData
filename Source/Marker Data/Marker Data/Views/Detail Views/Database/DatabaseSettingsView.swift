//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct DatabaseSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    @EnvironmentObject var databaseManager: DatabaseManager
    
    @State var selection: String? = nil
    
    @State var showCreateProfileSheet = false
    /// If set to a ``DatabaseProfileModel`` the modal will let the user edit the profile instead of creating a new one
    @State var editProfile: DatabaseProfileModel? = nil
    
    @State var showProfileCreateAlert = false
    @State var profileCreateMessage = ""
    
    @State var showProfileRemoveAlert = false
    @State var showDuplicationAlert = false
    
    var body: some View {
        VStack {
            tableView
            
            profileManagementButtons
            
            Spacer()
                .frame(height: 30)
            
            linksView
        }
        .padding()
        .overlayHelpButton(url: Links.databaseSettingsURL)
        .navigationTitle("Database Settings")
        .sheet(isPresented: $showCreateProfileSheet) {
            CreateDBProfileSheet(
                editProfile: $editProfile,
                showSelf: $showCreateProfileSheet,
                showAlert: $showProfileCreateAlert,
                alertMessage: $profileCreateMessage
            )
            .padding()
            .frame(minWidth: 600)
        }
        .alert("Failed to save profile", isPresented: $showProfileCreateAlert) { } message: {
            Text(profileCreateMessage)
        }
        .alert("Failed to remove profile", isPresented: $showProfileRemoveAlert) { }
        .alert("Failed to duplicate profile", isPresented: $showDuplicationAlert) { }
    }
    
    var tableView: some View {
        Table(databaseManager.profiles, selection: $selection) {
            TableColumn("Profile Name", value: \.name)
            TableColumn("Platform", value: \.plaform.rawValue)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    var profileManagementButtons: some View {
        HStack {
            // Add profile button
            Button {
                showCreateProfileSheet = true
            } label: {
                Image(systemName: "plus")
            }
            
            // Remove profile button
            Button {
                do {
                    try withAnimation {
                        try databaseManager.removeProfile(profileName: selection ?? "")
                    }
                } catch {
                    showProfileRemoveAlert = true
                }
            } label: {
                Image(systemName: "minus")
            }
            .disabled(selection == nil)
            
            Divider()
                .frame(height: 20)
            
            // Editing buttons
            HStack {
                // Edit button
                Button {
                    if let profileToEdit = databaseManager.profiles.first(where: { $0.name == selection }) {
                        editProfile = profileToEdit
                        showCreateProfileSheet = true
                    }
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                
                // Duplicate button
                Button {
                    if let profileName = selection {
                        do {
                            try databaseManager.duplicateProfile(profileName: profileName)
                        } catch {
                            showDuplicationAlert = true
                        }
                    }
                } label: {
                    Label("Duplicate", systemImage: "square.filled.on.square")
                }
            }
            .disabled(selection == nil)
            
            Spacer()
        }
    }
    
    var linksView: some View {
        HStack {
            Button() {
                NSWorkspace.shared.open(
                    URL(fileURLWithPath: URL.databaseFolder.path().removingPercentEncoding ?? "")
                )
            } label: {
                Label("Open Database Folder in Finder", systemImage: "folder")
            }
            .buttonStyle(.link)
            
            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)
            
            Link(destination: Links.airtableTemplateURL) {
                Label("Airtable Template", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            
            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)
            
            Link(destination: Links.notionTemplateURL) {
                Label("Notion Template", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            
            Spacer()
        }
    }
}

struct DatabaseSettingsView_Previews: PreviewProvider {
    static let settings = SettingsContainer()
    static let databaseManager = DatabaseManager()
    
    static var previews: some View {
        DatabaseSettingsView()
            .environmentObject(settings)
            .environmentObject(databaseManager)
    }
}