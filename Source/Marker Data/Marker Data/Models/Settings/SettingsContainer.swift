//
//  SettingsContainer.swift
//  Marker Data
//
//  Created by Milán Várady on 19/10/2023.
//

import Foundation
import AppKit
import Combine
import OSLog

/// Holds app settings and provides methods to save, delete and modify them
@MainActor
class SettingsContainer: ObservableObject {
    @Published var store: SettingsStore
    @Published var unsavedChanges = false

    var isDefaultActive: Bool {
        self.store.name == SettingsStore.defaultName
    }

    var configurations: [SettingsStore]

    private var cancellables = Set<AnyCancellable>()

    /// Avoids recursion when checking for unsaved changes
    @MainActor
    private var ignoreWillChange = false

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsContainer")

    init() {
        // Check & update versions
        Task.synchronous {
            await SettingsVersioningManager.updateAll()
        }

        self.store = .defaults()
        self.configurations = []

        do {
            self.store = try self.loadStoreFromDisk(at: URL.preferencesJSON)
        } catch {
            Self.logger.warning("Failed to load settings store. Keeping defaults. \(error.localizedDescription)")
        }

        self.configurations.append(contentsOf: self.loadConfigurationsFromDisk())

        Task {
            do {
                try await self.store.saveAsCurrent()
            } catch {
                Self.logger.error("Failed to save store during init")
            }

            await self.checkForUnsavedChanges()
        }

        // Save file when changes are made
        self.objectWillChange.sink { _ in
            Task(priority: .background) {
                if !self.ignoreWillChange {
                    try await self.store.saveAsCurrent()
                    await self.checkForUnsavedChanges()
                }

                await MainActor.run {
                    self.ignoreWillChange = false
                }
            }
        }
        .store(in: &cancellables)

        // Monitor roles for changes
        // We need this because the roles might be changed from the FCP Workflow Extension
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(updateRoles),
            name: Notification.Name("RolesChanged"),
            object: nil)
    }

    public func load(_ store: SettingsStore) throws {
        // Default
        if store.isDefault() {
            self.setCurrent(SettingsStore.defaults())
            return
        }

        let store = try self.loadStoreFromDisk(at: store.jsonURL)

        self.setCurrent(store)
    }

    /// Saves current as a configuration
    public func saveCurrentAs(name: String) async throws {
        try await self.duplicateStore(store: self.store, as: name, setAsCurrent: true)
    }

    /// Duplicates a store
    public func duplicateStore(store: SettingsStore, as name: String, setAsCurrent: Bool = false) async throws {
        if name == SettingsStore.defaultName {
            throw ConfigurationSaveError.illegalName
        }

        guard var duplicate = deepCopy(of: store) else {
            throw ConfigurationSaveError.duplicationError
        }

        duplicate.name = name
        
        try await duplicate.saveAsConfiguration()

        self.configurations.append(duplicate)
        
        if setAsCurrent {
            self.setCurrent(duplicate)
        }
    }

    /// Removes a configuration by name
    public func removeConfiguration(name: String) async throws {
        if let index = self.configurations.firstIndex(where: { $0.name == name }) {
            let wasActive = isStoreActive(self.configurations[index])

            // Delete file
            try self.configurations[index].delete()

            // Remove model
            self.configurations.remove(safeAt: index)

            // Select a new active conf if the deleted one was active
            if wasActive {
                if let newStore = self.configurations.first {
                    self.setCurrent(newStore)
                    try await newStore.saveAsCurrent()
                }
            }

            self.objectWillChange.send()
        }
    }

    /// Reloads current store from disk
    public func discardChanges() throws {
        self.store = try self.loadStoreFromDisk(at: self.store.jsonURL)
    }

    @MainActor
    public func findByName(_ name: String) -> SettingsStore? {
        if name.isEmpty {
            return nil
        }

        guard let store = self.configurations.first(where: { $0.name == name }) else {
            Self.logger.error("Failed to find conf: \(name)")
            return nil
        }

        return store
    }

    // Check if a store object is the current one
    public func isStoreActive(_ store: SettingsStore) -> Bool {
        return self.store.name == store.name
    }

    /// Sets the current store
    private func setCurrent(_ store: SettingsStore) {
        self.store = store
        self.objectWillChange.send()
    }

    /// Loads a settings store from disk
    private func loadStoreFromDisk(at url: URL) throws -> SettingsStore {
        let decoder = JSONDecoder()

        let data = try Data(contentsOf: url)
        let decoded = try decoder.decode(SettingsStore.self, from: data)
        
        // Check if configuration file exists
        if !decoded.jsonURL.fileExists && !decoded.isDefault() {
            Self.logger.warning("Failed to load store from disk. Configuration named \"\(decoded.name)\" missing. Returning default.")
            return SettingsStore.defaults()
        }

        return decoded
    }

    /// Loads all settings store obejcts from disk
    private func loadConfigurationsFromDisk() -> [SettingsStore] {
        let filemanager = FileManager.default

        // Scan the configuration directory for configuration files
        guard let urls = try? filemanager.contentsOfDirectory(at: URL.configurationsFolder, includingPropertiesForKeys: []) else {
            return []
        }

        var configurations: [SettingsStore] = [SettingsStore.defaults()]

        for url in urls {
            if url.conformsToType([.json]) {
                do {
                    let config = try self.loadStoreFromDisk(at: url)
                    configurations.append(config)
                } catch {
                    Self.logger.error("Failed to load config at: \(url.path(percentEncoded: false)). \(error.localizedDescription)")
                }
            }
        }

        return configurations
    }

    /// Compares current store with the one on disk
    public func checkForUnsavedChanges() async {
        await MainActor.run {
            self.ignoreWillChange = true
        }

        // In case of default
        if isDefaultActive {
            self.unsavedChanges = self.store != SettingsStore.defaults()
            return
        }

        guard let onDisk = try? self.loadStoreFromDisk(at: self.store.jsonURL) else {
            Self.logger.error("Failed to load conf: \(self.store.jsonURL) to check for changes.")
            return
        }

        self.unsavedChanges = onDisk != self.store
    }

    @objc
    private func updateRoles() {
        do {
            Self.logger.notice("Roles have been modified from outside. Loading new store.")
            
            let storeOnDisk = try self.loadStoreFromDisk(at: URL.preferencesJSON)
            self.store = storeOnDisk
        } catch {
            Self.logger.error("Failed to load new roles: \(error.localizedDescription)")
        }
    }
}
