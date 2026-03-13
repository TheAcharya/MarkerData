//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI
import Sparkle

struct GeneralSettingsView: View {
    let updater: SPUUpdater

    @Environment(\.openURL) var openURL
    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        TabView {
            Tab("File", systemImage: "folder") {
                FileSettingsView()
            }

            Tab("Roles", systemImage: "movieclapper") {
                RolesSettingsView()
                    .padding()
                    .padding(.bottom)
            }

            Tab("Notifications", systemImage: "bell.badge") {
                NotificationSettingsView()
            }

            Tab("Updates", systemImage: "arrow.clockwise") {
                UpdateSettingsView(updater: updater)
            }
        }
        .padding(.top)
        .overlayHelpButton(url: Links.generalSettingsURL)
    }
}

#Preview {
    let settings = SettingsContainer()
    let databaseManager = DatabaseManager(settings: settings)

    return GeneralSettingsView(updater: SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil).updater)
            .preferredColorScheme(.dark)
            .environmentObject(settings)
            .environmentObject(databaseManager)
            .padding()
}
