//
//  ConfigurationsViewModel.swift
//  Marker Data
//
//  Created by Milán Várady on 20/02/2024.
//

import Foundation

class ConfigurationsViewModel: ObservableObject {
    var settings: SettingsContainer? = nil

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    public func add(saveAs name: String) {
        Task {
            do {
                try await settings?.saveCurrentAs(name: name)
            } catch {
                await showAlert("Couldn't create configuration", message: error.localizedDescription)
            }
        }
    }

    public func remove(name: String) {
        Task {
            do {
                try await settings?.removeConfiguration(name: name)
            } catch {
                await showAlert("Failed to remove configuration", message: error.localizedDescription)
            }
        }
    }

    @MainActor 
    public func makeActive(_ store: SettingsStore?, ignoreChanges: Bool = false) {
        guard let storeUnwrapped = store else {
            showAlert("Failed to load configuration")
            return
        }

        Task {
            await MainActor.run {
                do {
                    try settings?.load(storeUnwrapped)
                } catch {
                    showAlert("Failed to load configuration", message: error.localizedDescription)
                }
            }
        }
    }

    public func updateCurrent() {
        Task {
            do {
                try await settings?.store.saveAsConfiguration()
                await settings?.checkForUnsavedChanges()
            } catch {
                await showAlert("Failed to update active configuration", message: error.localizedDescription)
            }
        }
    }

    @MainActor 
    public func discardChanges() {
        do {
            try settings?.discardChanges()
        } catch {
            showAlert("Failed to discard changes", message: error.localizedDescription)
        }
    }

    public func rename(store: SettingsStore?, to newName: String) async {
        guard let jsonURL = store?.jsonURL,
              let loadedStore = try? await settings?.loadStoreFromDisk(at: jsonURL) else {
            await showAlert("Failed to rename")
            return
        }

        do {
            try await settings?.duplicateStore(store: loadedStore, as: newName, setAsCurrent: true)
            try await settings?.removeConfiguration(name: loadedStore.name)
        } catch {
            await showAlert("Failed to rename", message: error.localizedDescription)
        }
    }

    @MainActor
    private func showAlert(_ title: String, message: String = "") {
        self.showAlert = true
        self.alertTitle = title
        self.alertMessage = message
    }
}
