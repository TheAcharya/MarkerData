//
//  RolesManager.swift
//  Marker Data
//
//  Created by Milán Várady on 27/01/2024.
//

import Foundation
import OSLog
import EonilFSEvents

/// The roles manager manages the selected FCP roles
///
/// It is designed to work without models such as the ``SettingsContainer`` because this
/// view needs to be accessible from the FCP Workflow Extension which cannot access the models
/// of the running app instance.
class RolesManager: ObservableObject {
    @MainActor
    @Published var roles: [RoleModel] = []
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RolesManager")

    static let staticPreferencesJSONURL = URL(filePath: "/Users/\(NSUserName())/Library/Application Support/Marker Data/preferences.json")

    init() {
        Task {
            await MainActor.run {
                self.roles = Self.loadRolesFromDisk()
            }
        }

        // Monitor preferences file for changes
        // We need this because the roles might be changed from the FCP Workflow Extension
        do {
            try EonilFSEvents.startWatching(
                paths: [Self.staticPreferencesJSONURL.path(percentEncoded: false)],
                for: ObjectIdentifier(self),
                with: { event in
                    Task {
                        do {
                            let storeOnDisk = try Self.loadStore()

                            await MainActor.run {
                                self.roles = storeOnDisk.roles
                            }

                            Self.logger.notice("Roles have been modified from outside. Loading new roles.")
                        } catch {
                            Self.logger.error("File monitor error: \(error.localizedDescription)")
                        }
                    }
                })
        } catch {
            Self.logger.warning("Failed to start roles monitoring. \(error.localizedDescription)")
        }
    }

    @MainActor
    func save() throws {
        try self.saveRolesToDisk(self.roles)
    }
    
    @MainActor
    func setRoles(_ roles: [RoleModel]) {
        self.roles = roles
        
        do {
            try self.saveRolesToDisk(roles)
        } catch {
            Self.logger.error("Failed to save roles to disk: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    @MainActor
    func refresh() {
        self.roles = Self.loadRolesFromDisk()
    }
    
    @MainActor
    func enableAll() {
        self.setRoles(self.roles.map { RoleModel(role: $0.role, enabled: true) })
    }
    
    @MainActor
    func disableAll() {
        self.setRoles(self.roles.map { RoleModel(role: $0.role, enabled: false) })
    }
    
    // MARK: Static methods

    @MainActor
    func saveRolesToDisk(_ roles: [RoleModel]) throws {
        var store = try Self.loadStore()

        store.roles = self.roles

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(store)
        
        try data.write(to: Self.staticPreferencesJSONURL)
    }
    
    static func loadRolesFromDisk() -> [RoleModel] {
        do {
            let store = try Self.loadStore()

            let roles = store.roles

            return roles
        } catch {
            Self.logger.error("Failed to decode preferences.json: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private static func loadStore() throws -> SettingsStore {
        let decoder = JSONDecoder()

        let data = try Data(contentsOf: Self.staticPreferencesJSONURL)
        let decoded = try decoder.decode(SettingsStore.self, from: data)

        return decoded
    }
}
