//
//  DatabaseManager.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import Foundation
import SwiftUI
import MarkersExtractor
import os

/// Holds and manages database profiles
@MainActor
class DatabaseManager: ObservableObject {
    /// List of database profiles
    @Published var profiles: [DatabaseProfileModel] = []
    @AppStorage("selectedDatabaseProfileName") var selectedDatabaseProfileName = ""
    @AppStorage("selectedExportFormat") var selectedExportFormat: ExportProfileFormat = .notion
    
    var selectedDatabaseProfile: DatabaseProfileModel? {
        if let activeProfileName = UserDefaults.standard.string(forKey: "selectedDatabaseProfile"),
           let profile = self.profiles.first(where: { $0.name == activeProfileName }) {
            return profile
        } else {
            return nil
        }
    }
    
    static let logger = Logger()
    
    init() {
        self.createConfigurationsDirectory()
        self.loadProfilesFromDisk()
        
        // Create database directories if they don't exist already
        let fileManager = FileManager.default
        var isDir: ObjCBool = true
        
        do {
            if !fileManager.fileExists(atPath: URL.databaseFolder.path(percentEncoded: false), isDirectory: &isDir) {
                Self.logger.notice("Database folder missing: Attempting to create it")
                try fileManager.createDirectory(at: URL.databaseFolder, withIntermediateDirectories: true)
            }
            
            if !fileManager.fileExists(atPath: URL.databaseProfilesFolder.path(percentEncoded: false), isDirectory: &isDir) {
                Self.logger.notice("Database Profiles folder missing: Attempting to create it")
                try fileManager.createDirectory(at: URL.databaseProfilesFolder, withIntermediateDirectories: true)
            }
        } catch {
            Self.logger.error("Failed to create Database folders")
        }
    }
    
    /// Set export profile without uploading to any database
    public func setExportProfile(exportProfile profile: ExportProfileFormat) {
        self.selectedExportFormat = profile
        self.selectedDatabaseProfileName = ""
    }
    
    /// Set export profile and database upload settings
    public func setExportProfile(databaseProfileName: String) {
        if let profile = self.profiles.first(where: { $0.name == databaseProfileName }) {
            self.selectedExportFormat = profile.plaform.asExportProfile
            self.selectedDatabaseProfileName = profile.name
        }
    }
    
    func addProfile(_ profile: DatabaseProfileModel, saveToDisk: Bool = true) throws {
        if saveToDisk {
            try self.validateProfile(profile)
            try self.saveProfileToDisk(profile)
        }
        
        self.profiles.append(profile)
    }
    
    func removeProfile(profileName: String) throws {
        guard let profile = self.profiles.first(where: { $0.name == profileName }) else {
            throw DatabaseRemoveError.profileDoesntExist
        }
        
        // Delete file
        let filemanager = FileManager()
        let url = URL.databaseProfilesFolder
            .appendingPathComponent("\(profile.name).json", conformingTo: .json)
        
        try filemanager.removeItem(at: url)
        
        // Remove from list
        if let index = self.profiles.firstIndex(of: profile) {
            self.profiles.remove(at: index)
        }
    }
    
    func setActiveProfile(profileName: String) {
        Task {
            await MainActor.run {
                if let profile = self.profiles.first(where: { $0.name == profileName }) {
                    self.selectedDatabaseProfileName = profile.name
                }
            }
        }
    }
    
    func duplicateProfile(profileName: String) throws {
        Task {
            try await MainActor.run {
                guard let profile = self.profiles.first(where: { $0.name == profileName }) else {
                    throw DatabaseProfileDuplicationError.noProfileFound
                }
                
                let duplicate = profile.copy()
                try self.addProfile(duplicate, saveToDisk: true)
            }
        }
    }
    
    /// Saves a profile to disk
    private func saveProfileToDisk(_ profile: DatabaseProfileModel) throws {
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(profile)
        let url = URL.databaseProfilesFolder.appendingPathComponent(profile.name, conformingTo: .json)
        
        try data.write(to: url)
    }
    
    private func loadProfilesFromDisk() {
        let filemanager = FileManager.default
        let decoder = JSONDecoder()
        
        let profilesFolderString = URL.databaseProfilesFolder.path().removingPercentEncoding!
        
        // Loop through all the files in the folder
        if let profileNames = try? filemanager.contentsOfDirectory(atPath: profilesFolderString) {
            for profileName in profileNames {
                if profileName.hasSuffix(".json") {
                    let url = URL.databaseProfilesFolder.appendingPathComponent(profileName, conformingTo: .json)
                    
                    // Try to decode the profiles and append to profile list
                    do {
                        let data = try Data(contentsOf: url)
                        let decoded = try decoder.decode(DatabaseProfileModel.self, from: data)
                        
                        Task {
                            try await MainActor.run {
                                try self.addProfile(decoded, saveToDisk: false)
                            }
                        }
                    } catch {
                        Self.logger.error("Failed to load DB Profile at path: \(url.path(percentEncoded: false))")
                        continue
                    }
                }
            }
        }
    }
    
    /// Creates database profiles directory in Application Support if it doesn't exist already
    private func createConfigurationsDirectory() {
        let fileManager = FileManager.default
        
        let pathString = URL.databaseProfilesFolder.path().removingPercentEncoding ?? ""
        var isDir : ObjCBool = false
        
        if !fileManager.fileExists(atPath: pathString, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: URL.databaseProfilesFolder, withIntermediateDirectories: true)
            } catch {
                Self.logger.error("Failed to create Database Profiles directory")
            }
        }
    }
    
    /// Validates a database profile
    ///
    /// Checks if the name is not empty and not already used. Checks if API credentials are defined.
    ///
    /// - Parameters:
    ///     - profile: ``DatabaseProfileModel`` to validate
    ///     - ingoreName: If set this name will be ignored when checking for existing names. (Used when editing a profile)
    func validateProfile(_ profile: DatabaseProfileModel, ignoreName: String? = nil) throws {
        // Check if name is empty
        if profile.name.isEmpty {
            throw DatabaseValidationError.emptyName
        }
        
        // Check for illegal names (names of no upload exports)
        let illegalNames = ExportProfileFormat.allExtractOnlyNames
        
        if illegalNames.contains(profile.name) {
            throw DatabaseValidationError.illegalName
        }
        
        // Check if name already exists
        if let matchingProfile = self.profiles.first(where: { $0.name == profile.name }) {
            if matchingProfile.name != ignoreName {
                throw DatabaseValidationError.nameAlreadyExists
            }
        }
        
        // Check if credentials (e.g. tokens, API Keys) are defined
        let isNotionCredentialsEmpty = profile.notionCredentials?.token.isEmpty ?? true
        let isAirtableCredentialsEmpty = (profile.airtableCredentials?.apiKey.isEmpty ?? true) || (profile.airtableCredentials?.baseID.isEmpty ?? true)
        
        if isNotionCredentialsEmpty == isAirtableCredentialsEmpty {
            throw DatabaseValidationError.emptyCredentials
        }
        
        if (profile.notionCredentials == nil) == (profile.airtableCredentials == nil) {
            throw DatabaseValidationError.emptyCredentials
        }
    }
}
