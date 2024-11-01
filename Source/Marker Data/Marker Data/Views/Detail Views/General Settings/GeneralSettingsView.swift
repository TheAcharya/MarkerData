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
            FileSettingsView()
                .tabItem { Label("File", systemImage: "folder") }

            RolesSettingsView()
                .padding()
                .padding(.bottom)
                .tabItem { Label("Roles", systemImage: "movieclapper") }

            NotificationSettingsView()
                .tabItem { Label("Notifications", systemImage: "bell.badge") }
            
            UpdateSettingsView(updater: updater)
                .tabItem { Label("Updates", systemImage: "arrow.clockwise") }
        }
        .padding(.top)
        .overlayHelpButton(url: Links.generalSettingsURL)
        .navigationTitle("General Settings")
        
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
