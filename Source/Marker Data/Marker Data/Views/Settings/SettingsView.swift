//
//  SettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationFrequency") var notificationFrequency: NotificationFrequency = .onlyOnCompletion
    
    var body: some View {
        VStack {
            Text("General settings")
                .font(.title)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                Text("Notification Frequency")
                    .font(.title3)
                Text("Select when do you want to be notified.")
                    .fontWeight(.thin)
                
                Picker("Notification Frequency", selection: $notificationFrequency) {
                    ForEach(NotificationFrequency.allCases) { frequency in
                        Text(frequency.displayName)
                            .tag(frequency)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
