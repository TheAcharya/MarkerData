//
//  UpdateSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 29/02/2024.
//

import SwiftUI
import Sparkle

struct UpdateSettingsView: View {
    private let updater: SPUUpdater

    @State private var automaticallyChecksForUpdates: Bool
    @State private var automaticallyDownloadsUpdates: Bool

    init(updater: SPUUpdater) {
        self.updater = updater
        self.automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
        self.automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
    }


    var body: some View {
        VStack {
            CheckForUpdatesView(updater: updater) {
                Label("Check for Updates...", systemImage: "arrow.uturn.down")
            }

            Text("Current app version: \(Bundle.main.version) (\(Bundle.main.buildNumber))")
                .font(.system(.body, weight: .light))
                .foregroundColor(.secondary)

            Spacer()
                .frame(height: 20)

            Toggle("Automatically check for updates", isOn: $automaticallyChecksForUpdates)
                .onChange(of: automaticallyChecksForUpdates) { newValue in
                    updater.automaticallyChecksForUpdates = newValue
                }

            Toggle("Automatically download updates", isOn: $automaticallyDownloadsUpdates)
                .disabled(!automaticallyChecksForUpdates)
                .onChange(of: automaticallyDownloadsUpdates) { newValue in
                    updater.automaticallyDownloadsUpdates = newValue
                }
        }
    }
}

#Preview {
    UpdateSettingsView(updater: SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil).updater)
}
