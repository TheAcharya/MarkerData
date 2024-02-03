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
            Text("Progress Reporting")
                .font(.headline)
            
            HStack {
                Text("Notification Frequency:")
                
                Picker("", selection: $settings.store.notificationFrequency) {
                    ForEach(NotificationFrequency.allCases) { frequency in
                        Text(frequency.displayName)
                            .tag(frequency)
                    }
                }
                .labelsHidden()
                .frame(width: 250)
                .formControlLeadingAlignmentGuide()
            }
            
            HStack {
                Text("Show Progress on Dock Icon: ")
                
                Toggle("", isOn: $settings.store.showDockProgress)
                    .formControlLeadingAlignmentGuide()
            }
            .padding(.bottom)
            
            Button("Open macOS Notification Settings") {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")!)
            }
            .buttonStyle(.link)
        }
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    @StateObject var databaseManager = DatabaseManager()
    @StateObject var configurationsModel = ConfigurationsModel()
    
    return NotificationSettingsView()
        .preferredColorScheme(.dark)
        .environmentObject(settings)
        .environmentObject(databaseManager)
        .environmentObject(configurationsModel)
        .padding()
}
