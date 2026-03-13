//
//  NotificationSettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 25/01/2024.
//

import SwiftUI

struct NotificationSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    
    var body: some View {
        VStack {
            Spacer()
            
            Form {
                Section(header: SectionHeader("Progress Reporting")) {
                    Picker("Notification Frequency", selection: $settings.store.notificationFrequency) {
                        ForEach(NotificationFrequency.allCases) { frequency in
                            Text(frequency.displayName)
                                .tag(frequency)
                        }
                    }

                    Toggle("Show Progress on Dock Icon", isOn: $settings.store.showDockProgress)
                }
            }
            
            Spacer()

            SettingsLinks()
        }
    }
    
    private struct SettingsLinks: View {
        var body: some View {
            HStack {
                Button {
                    if let notificationSettingsURL = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") {
                        NSWorkspace.shared.open(notificationSettingsURL)
                    }
                } label: {
                    Label("Open macOS Notification Settings", systemImage: "bell.badge")
                }
                .buttonStyle(.link)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    let settings = SettingsContainer()
    let databaseManager = DatabaseManager(settings: settings)
    
    return NotificationSettingsView()
        .preferredColorScheme(.dark)
        .environmentObject(settings)
        .environmentObject(databaseManager)
        .padding()
}
