//
//  ConfigurationsViewModel.swift
//  Marker Data
//
//  Created by Milán Várady on 20/02/2024.
//

import Foundation

@MainActor
class ConfigurationsViewModel: ObservableObject {
    var settings: SettingsContainer? = nil

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    @discardableResult
    public func add(saveAs name: String) async -> Bool {
        do {
            try await settings?.saveCurrentAs(name: name)
            return true
        } catch {
            showAlert("Couldn't create configuration", message: error.localizedDescription)
            return false
        }
    }

    public func remove(name: String) async {
        do {
            try await settings?.removeConfiguration(name: name)
        } catch {
            showAlert("Failed to remove configuration", message: error.localizedDescription)
        }
    }

    public func makeActive(_ store: SettingsStore?, ignoreChanges: Bool = false) {
        guard let storeUnwrapped = store else {
            showAlert("Failed to get configuration")
            return
        }

        do {
            try settings?.load(storeUnwrapped)
        } catch {
            showAlert("Failed to load configuration", message: error.localizedDescription)
        }
    }

    public func duplicateConfiguration(store: SettingsStore?) async {
        guard let storeUnwrapped = store else {
            showAlert("Failed to get configuration")
            return
        }

        do {
            try await settings?.duplicateStore(store: storeUnwrapped, as: storeUnwrapped.name + " copy")
            settings?.objectWillChange.send()
        } catch {
            showAlert("Failed to duplicate configuration", message: error.localizedDescription)
        }
    }

    public func updateCurrent() async {
        do {
            try await settings?.store.saveAsConfiguration()
            await settings?.checkForUnsavedChanges()
        } catch {
            showAlert("Failed to update active configuration", message: error.localizedDescription)
        }
    }

    public func discardChanges() {
        do {
            try settings?.discardChanges()
        } catch {
            showAlert("Failed to discard changes", message: error.localizedDescription)
        }
    }

    @discardableResult
    public func rename(store: SettingsStore?, to newName: String) async -> Bool {
        guard let jsonURL = store?.jsonURL,
              let loadedStore = try? settings?.loadStoreFromDisk(at: jsonURL) else {
            showAlert("Failed to rename")
            return false
        }

        if newName == loadedStore.name {
            return true
        }

        do {
            try await settings?.duplicateStore(store: loadedStore, as: newName, setAsCurrent: true)
            try await settings?.removeConfiguration(name: loadedStore.name)
            return true
        } catch {
            showAlert("Failed to rename", message: error.localizedDescription)
            return false
        }
    }

    private func showAlert(_ title: String, message: String = "") {
        self.showAlert = true
        self.alertTitle = title
        self.alertMessage = message
    }
}
