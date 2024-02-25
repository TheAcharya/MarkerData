//
//  ExportProfilePicker.swift
//  Marker Data
//
//  Created by Milán Várady on 02/12/2023.
//

import SwiftUI
import Combine
import MarkersExtractor

struct ExportProfilePicker: View {
    @EnvironmentObject var settings: SettingsContainer
    @EnvironmentObject var databaseManager: DatabaseManager
    
    var body: some View {
        Picker("Export Profile", selection: $settings.store.unifiedExportProfile) {
            Section("Extract Only (No Upload)") {
                ForEach(UnifiedExportProfile.noUploadProfiles) { profile in
                    Label {
                        Text(profile.displayName)
                    } icon: {
                        ResizedImage(profile.iconImageName, width: 20, height: 20)
                    }
                    .tag(Optional(profile))
                }
            }
            
            Divider()
            
            Section("Database Profiles (Upload)") {
                ForEach(databaseManager.getUnifiedExportProfiles()) { profile in
                    Label {
                        Text(profile.displayName)
                    } icon: {
                        ResizedImage(profile.iconImageName, width: 20, height: 20)
                    }
                    .tag(Optional(profile))
                }
            }
        }
        .labelStyle(.titleAndIcon)
        .onAppear {
            // TODO: check this
//            self.configurationUpdaterCancellable = configurationsModel.changePublisher
//                .sink {
//                    if let unifiedProfile = UnifiedExportProfile.load() {
//                        self.selection = unifiedProfile
//                    }
//                }
            
            // To avoid getting errors like Picker: the selection ... is invalid
            // Uncomment the code below to set the selection with a delay
            // We need to wait until the picker is fully initialized to not get the error
            // But the picker works anyways just the error is kinda annoying
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.selection = UnifiedExportProfile.load()
//            }
        }
    }
}

#Preview {
    ExportProfilePicker()
}
