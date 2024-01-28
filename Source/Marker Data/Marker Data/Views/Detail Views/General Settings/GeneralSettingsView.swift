//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.openURL) var openURL

    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        TabView {
            FileSettingsView()
                .tabItem { Label("File", systemImage: "folder") }
            
            NotificationSettingsView()
                .tabItem { Label("Notifications", systemImage: "bell.badge") }
            
            RolesSettingsView()
                .padding()
                .padding(.bottom)
                .tabItem { Label("Roles", systemImage: "movieclapper") }
        }
        .padding(.top)
        .overlayHelpButton(url: Links.generalSettingsURL)
        .navigationTitle("General Settings")
        
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    @StateObject static var settings = SettingsContainer()
    @StateObject static var databaseManager = DatabaseManager()
    @StateObject static var configurationsModel = ConfigurationsModel()
    
    static var previews: some View {
        GeneralSettingsView()
            .preferredColorScheme(.dark)
            .environmentObject(settings)
            .environmentObject(databaseManager)
            .environmentObject(configurationsModel)
            .padding()
    }
    
}
