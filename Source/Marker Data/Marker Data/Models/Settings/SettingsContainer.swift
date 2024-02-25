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
import EonilFSEvents

/// Manages and reloads settings
///
/// This container object is needed because when we load a
/// configuraition using ``ConfigurationsModel`` the variables
/// inside ``SettingsStore`` that use the `@AppStorage` property wrapper sometimes stay unchanged.
/// With this container we can reload the whole settings object so our values are updated.
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
        }

        // Save file when changes are made
        self.objectWillChange.sink { _ in
            Task(priority: .background) {
                if await !self.ignoreWillChange {
                    try await self.store.saveAsCurrent()
                    await self.checkForUnsavedChanges()
                }

                await MainActor.run {
                    self.ignoreWillChange = false
                }
            }
        }
        .store(in: &cancellables)

        // Monitor preferences file for changes
        // We need this because the roles might be changed from the FCP Workflow Extension
        do {
            try EonilFSEvents.startWatching(
                paths: [URL.preferencesJSON.path(percentEncoded: false)],
                for: ObjectIdentifier(self),
                with: { event in
                    do {
                        let storeOnDisk = try self.loadStoreFromDisk(at: URL.preferencesJSON)

                        if storeOnDisk.roles != self.store.roles {
                            self.store = storeOnDisk
                            Self.logger.notice("Roles have been modified from outside. Loading new store.")
                        }
                    } catch {
                        Self.logger.error("File monitor error: \(error.localizedDescription)")
                    }
                })
        } catch {
            Self.logger.warning("Failed to start preferences file monitoring. \(error.localizedDescription)")
        }
    }

    /// Sets the current store by name
    // TODO: remove
//    @MainActor
//    public func setCurrent(name: String) throws {
//        guard let newStore = self.configurations.first(where: { $0.name == name }) else {
//            Self.logger.error("Failed to find conf: \(name) while setting current.")
//            throw StoreLocateError.storeNotFound
//        }
//        
//        self.setCurrent(newStore)
//    }

    @MainActor
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
    @MainActor
    public func saveCurrentAs(name: String) async throws {
        try await self.duplicateStore(store: self.store, as: name, setAsCurrent: true)
    }

    /// Duplicates a store
    @MainActor
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
    @MainActor
    public func removeConfiguration(name: String) async throws {
        if let index = self.configurations.firstIndex(where: { $0.name == name }) {
            let isActive = isStoreActive(self.configurations[index])

            try self.configurations[index].delete()
            self.configurations.remove(at: index)

            // Select a new active conf if the deleted one was active
            if isActive {
                try await self.configurations.first?.saveAsCurrent()
            }

            self.objectWillChange.send()
        }
    }

    /// Reloads current store from disk
    public func discardChanges() throws {
        self.store = try self.loadStoreFromDisk(at: self.store.jsonURL)
    }

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
    @MainActor
    private func setCurrent(_ store: SettingsStore) {
        // TODO: remove print
        print("setting as current: \(store.name)")
        self.store = store
        self.objectWillChange.send()
    }

    /// Loads a settings store from disk
    private func loadStoreFromDisk(at url: URL) throws -> SettingsStore {
        let decoder = JSONDecoder()

        let data = try Data(contentsOf: url)
        let decoded = try decoder.decode(SettingsStore.self, from: data)

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
    @MainActor
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
}
