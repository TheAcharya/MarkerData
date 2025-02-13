//
//  RolesManager.swift
//  Marker Data
//
//  Created by Milán Várady on 27/01/2024.
//

import Foundation
import OSLog

/// The roles manager manages the selected FCP roles
///
/// It is designed to work without models such as the ``SettingsContainer`` because this
/// view needs to be accessible from the FCP Workflow Extension which cannot access the models
/// of the running app instance.
@MainActor
class RolesManager: ObservableObject {
    @Published var roles: [RoleModel] = []
    @Published var loadingInProgress = false

    nonisolated static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RolesManager")
    nonisolated static let staticPreferencesJSONURL = URL(filePath: "/Users/\(NSUserName())/Library/Application Support/Marker Data/preferences.json")

    init() {
        self.roles = Self.loadRolesFromDisk()

        // Monitor roles for changes
        // We need this because the roles might be changed from the FCP Workflow Extension
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(refresh),
            name: .rolesChanged,
            object: nil)
    }

    func save() throws {
        try self.saveRolesToDisk(self.roles)
    }

    func setRoles(_ roles: [RoleModel]) {
        self.roles = roles
        
        do {
            try self.saveRolesToDisk(roles)
        } catch {
            Self.logger.error("Failed to save roles to disk: \(error.localizedDescription, privacy: .public)")
        }
    }

    @objc
    func refresh() {
        self.roles = Self.loadRolesFromDisk()
    }

    func enableAll() {
        self.setRoles(self.roles.map { RoleModel(role: $0.role, enabled: true) })
    }

    func disableAll() {
        self.setRoles(self.roles.map { RoleModel(role: $0.role, enabled: false) })
    }

    func performDrop() {
        self.loadingInProgress = true
    }

    // MARK: Static methods

    func saveRolesToDisk(_ roles: [RoleModel]) throws {
        var store = try Self.loadStore()

        store.roles = self.roles

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(store)
        
        try data.write(to: Self.staticPreferencesJSONURL)

        // Notify of changes
        DistributedNotificationCenter.default.post(name: .rolesChanged, object: nil)
    }
    
    nonisolated static func loadRolesFromDisk() -> [RoleModel] {
        do {
            let store = try Self.loadStore()

            let roles = store.roles

            return roles
        } catch {
            Self.logger.error("Failed to decode preferences.json: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    nonisolated private static func loadStore() throws -> SettingsStore {
        let decoder = JSONDecoder()

        let data = try Data(contentsOf: Self.staticPreferencesJSONURL)
        let decoded = try decoder.decode(SettingsStore.self, from: data)

        return decoded
    }
}
