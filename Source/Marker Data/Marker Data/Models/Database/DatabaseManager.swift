//
//  DatabaseManager.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import Foundation
import SwiftUI
import MarkersExtractor
import OSLog

/// Holds and manages database profiles
@MainActor
class DatabaseManager: ObservableObject {
    /// List of database profiles
    @Published var profiles: [DatabaseProfileModel] = []
    
    var selectedDatabaseProfile: DatabaseProfileModel? {
        get {
            let unifiedProfile = UnifiedExportProfile.load()
            guard let databaseProfile = self.profiles.first(where: { $0.name == unifiedProfile?.databaseProfileName }) else {
                return nil
            }
            
            return databaseProfile
        }
        
        set(value) {
            guard let databaseProfile = value else {
                Self.logger.error("Failed to save database profile as UnifiedExportProfile. Nil value found.")
                return
            }
            
            let unifiedProfile = UnifiedExportProfile(
                displayName: databaseProfile.name,
                extractProfile: databaseProfile.plaform.asExportProfile,
                databaseProfileName: databaseProfile.name,
                exportProfileType: .extractAndUpload
            )
            
            do {
                try unifiedProfile.save()
            } catch {
                Self.logger.error("Failed to save database profile as UnifiedExportProfile")
            }
        }
    }
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DatabaseManager")
    
    init() {
        self.loadProfilesFromDisk()
    }
    
    func addProfile(_ profile: DatabaseProfileModel, saveToDisk: Bool = true) throws {
        if saveToDisk {
            try self.validateProfile(profile)
            try self.saveProfileToDisk(profile)
        }
        
        self.profiles.append(profile)
    }
    
    func removeProfile(_ profile: DatabaseProfileModel, onlyFromDisk: Bool = false) throws {
        let filemanager = FileManager()
        try filemanager.removeItem(at: profile.getJSONURL())
        
        // Remove from list
        if !onlyFromDisk {
            if let index = self.profiles.firstIndex(of: profile) {
                self.profiles.remove(at: index)
            }
        }
    }
    
    func removeProfile(profileName: String) throws {
        guard let profile = self.profiles.first(where: { $0.name == profileName }) else {
            throw DatabaseRemoveError.profileDoesntExist
        }
        
        try self.removeProfile(profile)
    }
    
    func setActiveProfile(profileName: String) {
        Task {
            await MainActor.run {
                if let profile = self.profiles.first(where: { $0.name == profileName }) {
                    self.selectedDatabaseProfile = profile
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
                
                guard let duplicate = profile.copy() else {
                    throw DatabaseProfileDuplicationError.failedToDeepCopy
                }
                
                duplicate.name += " copy"
                
                try self.addProfile(duplicate, saveToDisk: true)
            }
        }
    }
    
    /// Saves a profile to disk
    public func saveProfileToDisk(_ profile: DatabaseProfileModel) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(profile)
        
        try data.write(to: profile.getJSONURL())
    }
    
    private func loadProfilesFromDisk() {
        func loopFolderAndAdd<T: DatabaseProfileModel>(at url: URL, as: T.Type) {
            let filemanager = FileManager.default
            let decoder = JSONDecoder()
            
            if let urls = try? filemanager.contentsOfDirectory(at: url, includingPropertiesForKeys: []) {
                for url in urls {
                    if !url.conformsToType([.json]) {
                        Self.logger.info("Loading DB profile: \(url, privacy: .public) doesn't conform to type JSON, skipping.")
                    }
                    
                    // Try to decode the profiles and append to profile list
                    do {
                        let data = try Data(contentsOf: url)
                        let decoded: DatabaseProfileModel = try decoder.decode(T.self, from: data)
                        
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
        
        loopFolderAndAdd(at: URL.notionProfilesFolder, as: NotionDBModel.self)
        loopFolderAndAdd(at: URL.airtableProfilesFolder, as: AirtableDBModel.self)
    }
    
    /// Returns all profiles as ``UnifiedExportProfile``
    public func getUnifiedExportProfiles() -> [UnifiedExportProfile] {
        let unifiedProfiles = self.profiles.map { profile in
            UnifiedExportProfile(
                displayName: profile.name,
                extractProfile: profile.plaform.asExportProfile,
                databaseProfileName: profile.name,
                exportProfileType: .extractAndUpload
            )
        }
        
        return unifiedProfiles
    }
    
    /// Validates a database profile
    ///
    /// Checks if the name is not empty and not already used. Checks if API credentials are defined.
    ///
    /// - Parameters:
    ///     - profile: ``DatabaseProfileModel`` to validate
    ///     - ingoreName: If set this name will be ignored when checking for existing names. (Used when editing a profile)
    func validateProfile(_ profile: DatabaseProfileModel, ignoreName: String? = nil) throws {
        // If required fields are not emtpy
        if !profile.validate() {
            throw DatabaseValidationError.emptyCredentials
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
    }
}
