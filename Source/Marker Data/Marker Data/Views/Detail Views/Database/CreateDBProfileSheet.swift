//
//  CreateDBProfileSheet.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import SwiftUI
import PasswordField

struct CreateDBProfileSheet: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    
    @Binding var editProfile: DatabaseProfileModel?
    @Binding var showSelf: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    @State var nameText: String = ""
    @State var selectedPlatform: DatabasePlatform = .notion
    
    @State var notionToken = ""
    @State var notionDatabaseURL = ""
    
    @State var airtableAPIKey = ""
    @State var airtableBaseID = ""
    
    @State var renameKeyColumn = ""
    
    @Environment(\.openURL) var openURL
    
    var inputValid: Bool {
        if !nameText.isEmpty {
            switch self.selectedPlatform {
            case .notion:
                return !notionToken.isEmpty
            case .airtable:
                return !airtableAPIKey.isEmpty && !airtableBaseID.isEmpty
            }
        }
        
        return false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(editProfile == nil ? "Create" : "Edit") Database Profile")
                .font(.system(size: 18, weight: .bold))
            
            HStack {
                Text("Name:")
                
                TextField("Profile Name", text: $nameText)
                    .textFieldStyle(.roundedBorder)
            }
            
            Picker("Platform", selection: $selectedPlatform) {
                ForEach(DatabasePlatform.allCases) { platform in
                    Text(platform.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .disabled(editProfile != nil)
            
            Divider()
                .padding(.vertical, 10)
            
            Group {
                switch selectedPlatform {
                case .notion:
                    notionFromView
                case .airtable:
                    airtableFormView
                }
            }
            .padding(.bottom)
            
            HStack {
                HelpButton(action: {
                    self.openURL(selectedPlatform == .airtable ? Links.airtableHelpURL : Links.notionHelpURL)
                })
                
                Spacer()
                
                Button("Cancel") {
                    self.reset()
                }
                
                Button("Save") {
                    self.saveProfile()
                }
                .disabled(!inputValid)
            }
        }
        // Set for editing
        .onAppear {
            if let profile = editProfile {
                self.nameText = profile.name
                
                if let notionCredentials = profile.notionCredentials {
                    self.selectedPlatform = .notion
                    self.notionToken = notionCredentials.token
                    self.notionDatabaseURL = notionCredentials.databaseURL ?? ""
                    self.renameKeyColumn = notionCredentials.renameKeyColumn ?? ""
                }
                
                if let airtableCredentials = profile.airtableCredentials {
                    self.selectedPlatform = .airtable
                    self.airtableAPIKey = airtableCredentials.apiKey
                    self.airtableBaseID = airtableCredentials.baseID
                    self.renameKeyColumn = airtableCredentials.renameKeyColumn ?? ""
                }
            }
        }
    }
    
    var notionFromView: some View {
        VStack {
            platformInfoTextField("Notion V2 Token", prompt: "Token", text: $notionToken, isRequired: true, secureField: true)
            
            platformInfoTextField("Notion Database URL", prompt: "Database URL", text: $notionDatabaseURL, isRequired: false, secureField: true)
            
            platformInfoTextField("Rename Key Column", prompt: "Different key column name in Notion (Default is \"Marker ID\")", text: $renameKeyColumn, isRequired: false)
        }
    }
    
    var airtableFormView: some View {
        VStack {
            platformInfoTextField("Airtable API Key", prompt: "API Key", text: $airtableAPIKey, isRequired: true, secureField: true)
            
            platformInfoTextField("Airtable Base ID", prompt: "Database URL", text: $airtableBaseID, isRequired: true, secureField: true)
            
            platformInfoTextField("Rename Key Column", prompt: "Different key column name in Notion (Default is \"Marker ID\")", text: $renameKeyColumn, isRequired: false)
        }
    }
    
    func platformInfoTextField(_ title: String, prompt: LocalizedStringKey, text: Binding<String>, isRequired: Bool = false, secureField: Bool = false) -> some View {
        HStack {
            Group {
                Text(title) +
                Text(" (\(isRequired ? "Required" : "Optional"))").fontWeight(.thin) +
                Text(":")
            }
            .padding(.trailing, -12)
            
            if secureField {
                PasswordField("", text: text) { isInputVisible in
                    // Visibility toggle button
                    Button {
                        isInputVisible.wrappedValue = isInputVisible.wrappedValue.toggled()
                    } label: {
                        Image(systemName: isInputVisible.wrappedValue ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                }
                .visibilityControlPosition(.inlineOutside)
                .textFieldStyle(.roundedBorder)
            } else {
                TextField(prompt, text: text)
                    .padding(.leading, 8)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                text.wrappedValue = ""
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
    }
    
    func saveProfile() {
        Task {
            await MainActor.run {
                let newProfile = self.makeProfile()
                var makeActive = false
                
                // If editing the profile
                if let oldProfile = editProfile {
                    // Validate new profile
                    do {
                        try self.databaseManager.validateProfile(newProfile, ignoreName: oldProfile.name)
                    } catch {
                        showAlert(error.localizedDescription)
                        reset()
                        return
                    }
                    
                    // Try to remove the old version of the profile
                    do {
                        // Remember if the profile was active or not
                        makeActive = databaseManager.selectedDatabaseProfile == oldProfile
                        
                        try databaseManager.removeProfile(profileName: oldProfile.name)
                    } catch {
                        showAlert("Failed to save changes")
                        reset()
                        return
                    }
                }
                
                do {
                    try self.databaseManager.addProfile(newProfile)
                    
                    if makeActive {
                        self.databaseManager.setActiveProfile(profileName: newProfile.name)
                    }
                } catch {
                    showAlert(error.localizedDescription)
                }
                
                reset()
            }
        }
    }
    
    func makeProfile() -> DatabaseProfileModel {
        switch self.selectedPlatform {
        case .notion:
            let credentials = NotionCredentials(
                token: self.notionToken,
                databaseURL: self.notionDatabaseURL, 
                renameKeyColumn: self.renameKeyColumn
            )
            
            return DatabaseProfileModel(
                name: nameText,
                plaform: selectedPlatform,
                notionCredentials: credentials,
                airtableCredentials: nil
            )
            
        case .airtable:
            let credentials = AirtableCredentials(
                apiKey: airtableAPIKey,
                baseID: airtableBaseID,
                renameKeyColumn: renameKeyColumn
            )
            
            return DatabaseProfileModel(
                name: nameText,
                plaform: selectedPlatform,
                notionCredentials: nil,
                airtableCredentials: credentials
            )
        }
    }
    
    func showAlert(_ message: String) {
        self.showAlert = true
        self.alertMessage = message
    }
    
    func reset() {
        self.showSelf = false
        self.editProfile = nil
    }
}

#Preview {
    CreateDBProfileSheet(editProfile: .constant(nil), showSelf: .constant(true), showAlert: .constant(false), alertMessage: .constant(""))
        .frame(maxWidth: 500)
        .padding()
}
