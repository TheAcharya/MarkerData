//
//  SettingsContainer.swift
//  Marker Data
//
//  Created by Milán Várady on 19/10/2023.
//

import Foundation
import AppKit
import Combine

/// Manages and reloads settings
///
/// This container object is needed because when we load a
/// configuraition using ``ConfigurationsModel`` the variables
/// inside ``SettingsStore`` that use the `@AppStorage` property wrapper sometimes stay unchanged.
/// With this container we can reload the whole settings object so our values are updated.
class SettingsContainer: ObservableObject {
    @Published var store = SettingsStore()
    
    let exportDestinationOpenPanel: NSOpenPanel = {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        return panel
    }()
    
    private var cancellables: Set<AnyCancellable> = []

    @Published var folderPickerDropDelegate = FolderPickerDropDelegate()
    
    init() {

        self.folderPickerDropDelegate.objectWillChange
            .sink(receiveValue: self.objectWillChange.send)
            .store(in: &self.cancellables)

        if let url = self.store.exportFolderURL {
            self.exportDestinationOpenPanel.directoryURL = url
        }

    }
    
    /// Reloads settings so that all values are updated
    @MainActor
    func reloadStore() async {
        await MainActor.run {
            self.store = SettingsStore()
        }
    }
}
