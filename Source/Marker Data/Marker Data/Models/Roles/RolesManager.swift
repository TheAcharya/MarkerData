//
//  RolesManager.swift
//  Marker Data
//
//  Created by Milán Várady on 27/01/2024.
//

import Foundation
import OSLog

class RolesManager: ObservableObject {
    @MainActor
    @Published var roles: [RoleModel] = []
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RolesManager")
    
    init() {
        Task {
            await MainActor.run {
                self.roles = Self.loadRolesFromDisk()
            }
        }
    }

    @MainActor
    func save() throws {
        try Self.saveRolesToDisk(self.roles)
    }
    
    @MainActor
    func setRoles(_ roles: [RoleModel]) {
        self.roles = roles
        
        do {
            try Self.saveRolesToDisk(roles)
        } catch {
            Self.logger.error("Failed to save roles to disk: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    @MainActor
    func refresh() {
        self.roles = Self.loadRolesFromDisk()
    }
    
    // MARK: Static methods
    @MainActor
    static func saveRolesToDisk(_ roles: [RoleModel]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(roles)
        let url = URL.rolesJSONStaticPath
        
        try data.write(to: url)
    }
    
    static func loadRolesFromDisk() -> [RoleModel] {
        let decoder = JSONDecoder()
        
        do {
            let data = try Data(contentsOf: URL.rolesJSONStaticPath)
            let decoded = try decoder.decode([RoleModel].self, from: data)
            
            return decoded
        } catch {
            Self.logger.error("Failed to decode roles.json: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }
}
