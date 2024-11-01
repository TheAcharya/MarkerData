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
        VStack(alignment: .formControlAlignment) {
            Spacer()
            
            Text("Progress Reporting")
                .font(.headline)
            
            LabeledFormElement("Notification Frequency") {
                Picker("", selection: $settings.store.notificationFrequency) {
                    ForEach(NotificationFrequency.allCases) { frequency in
                        Text(frequency.displayName)
                            .tag(frequency)
                    }
                }
                .frame(width: 250)
            }
            
            LabeledFormElement("Show Progress on Dock Icon") {
                Toggle("", isOn: $settings.store.showDockProgress)
            }
            
            Spacer()
            
            HStack {
                // Open preferences button
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
