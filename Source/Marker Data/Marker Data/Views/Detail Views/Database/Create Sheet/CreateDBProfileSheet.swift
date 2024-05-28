//
//  CreateDBProfileSheet.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import SwiftUI

struct CreateDBProfileSheet: View {
    @EnvironmentObject var databaseManager: DatabaseManager
    @Environment(\.openURL) var openURL

    @Binding var editProfile: DatabaseProfileModel?
    @Binding var showSelf: Bool

    @State var showAlert: Bool = false
    @State var alertMessage: String = ""

    @State var selectedProfileName: String = ""
    @State var selectedPlatform: DatabasePlatform = .notion
    
    @StateObject var notionProfile = NotionDBModel()
    @StateObject var airtableProfile = AirtableDBModel()
    
    var selectedProfile: DatabaseProfileModel {
        if let editProfileUnwrapped = editProfile {
            return editProfileUnwrapped
        }
        
        switch selectedPlatform {
        case .notion:
            return self.notionProfile
        case .airtable:
            return self.airtableProfile
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(editProfile == nil ? "Create" : "Edit") Database Profile")
                .font(.system(size: 18, weight: .bold))
            
            HStack {
                Text("Name:")
                
                TextField("Profile Name", text: $selectedProfileName)
                    .textFieldStyle(.roundedBorder)
            }
            
            Picker("Platform", selection: $selectedPlatform) {
                ForEach(DatabasePlatform.allCases) { platform in
                    Text(platform.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .disabled(editProfile != nil)
            .onAppear {
                if let editProfileUnwrapped = editProfile {
                    self.selectedProfileName = editProfileUnwrapped.name
                    self.selectedPlatform = editProfileUnwrapped.plaform
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            Group {
                switch selectedPlatform {
                case .notion:
                    NotionFormView(profileModel: (editProfile as? NotionDBModel) ?? notionProfile)
                case .airtable:
                    AirtableFormView(profileModel: (editProfile as? AirtableDBModel) ?? airtableProfile)
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
                .disabled(selectedProfileName.isEmpty)
            }
            .alert("Validation Error", isPresented: $showAlert) {} message: {
                Text(alertMessage)
            }
        }
    }
    
    func saveProfile() {
        Task {
            await MainActor.run {
                // If editing the profile
                if let editProfileUnwrapped = editProfile,
                   let profile = editProfileUnwrapped.copy() {
                    
                    // Validate new profile
                    do {
                        try self.databaseManager.validateProfile(profile, ignoreName: profile.name)
                    } catch {
                        showAlert(error.localizedDescription)
                        return
                    }
                    
                    // Remember if the profile was active or not
                    let makeActive = databaseManager.selectedDatabaseProfile?.name == profile.name
                    
                    // Remove old profile from disk and save new one
                    do {
                        try databaseManager.removeProfile(profile)
                        
                        // Set new name
                        profile.name = selectedProfileName
                        
                        try databaseManager.addProfile(profile)
                    } catch {
                        showAlert("Failed to save changes")
                        reset()
                        return
                    }
            
                    if makeActive {
                        self.databaseManager.setActiveProfile(profileName: selectedProfile.name)
                    }
                } else {
                    // Set profile name
                    selectedProfile.name = selectedProfileName

                    // Validate profile
                    do {
                        try self.databaseManager.validateProfile(selectedProfile)
                    } catch {
                        showAlert(error.localizedDescription)
                        return
                    }
                    
                    do {
                        try self.databaseManager.addProfile(selectedProfile)
                    } catch {
                        showAlert(error.localizedDescription)
                    }
                }
                
                reset()
            }
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
    CreateDBProfileSheet(editProfile: .constant(nil), showSelf: .constant(true))
        .frame(maxWidth: 800, minHeight: 400)
        .padding()
}
