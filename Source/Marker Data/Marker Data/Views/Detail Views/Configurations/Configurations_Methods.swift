//
//  Configurations_Methods.swift
//  Marker Data
//
//  Created by Milán Várady on 18/02/2024.
//

import SwiftUI

// TODO: delete file
//extension ConfigurationSettingsView {
//    func addConfiguration() {
//        Task {
//            do {
//                try await settings.saveCurrentAs(name: configurationNameText)
//            } catch {
//                configurationAddAlertMessage = error.localizedDescription
//                showConfigurationAddAlert = true
//            }
//        }
//
//        configurationNameText = ""
//        showAddConfigurationSheet = false
//    }
//
//    func removeConfiguration(_ store: SettingsStore?) {
//        guard let storeUnwrapped = store else {
//            showConfigurationDelteAlert = true
//            return
//        }
//
//        do {
//            try withAnimation {
//                try settings.removeConfiguration(storeUnwrapped)
//            }
//        } catch {
//            showConfigurationDelteAlert = true
//        }
//    }
//
//    func loadConfiguration(_ store: SettingsStore?, ignoreChanges: Bool = false) {
//        if settings.unsavedChanges && !ignoreChanges {
//            showSwitchUnsavedChangesDialog = true
//        } else {
//            guard let storeUnwrapped = store else {
//                showConfigurationLoadAlert = true
//                return
//            }
//
//            settings.setCurrent(storeUnwrapped)
//        }
//    }
//
//    func updateConfiguration(_ store: SettingsStore) {
//        Task {
//            do {
//                try await store.saveAsConfiguration()
//                await settings.checkForUnsavedChanges()
//            } catch {
//                showConfigurationUpdateAlert = true
//            }
//        }
//    }
//}
