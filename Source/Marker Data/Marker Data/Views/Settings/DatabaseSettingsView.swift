//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct DatabaseSettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore
    var body: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Connected Databases Table
                    //USE SWIFTUI TABLE COMPONENT
                    //Airtable Section
                    Text("Airtable")
                        .font(.title2)
                    HStack {
                        //Duplicate Airtable Template Button
                        Button(action: {}) {
                            Text("Duplicate Airtable Template")
                        }
                        .padding(.trailing)
                        //Find User API Key Button
                        Button(action: {}) {
                            Text("Find API Key")
                        }
                        .padding(.trailing)
                        //Find Base ID Button
                        Button(action: {}) {
                            Text("Find Base ID")
                        }
                    }
                    //Notion Section
                    Text("Notion")
                        .font(.title2)
                    HStack {
                        //Button To Duplicate Notion Template
                        Button(action: {}) {
                            Text("Duplicate Notion Template Button")
                        }
                        .padding(.trailing)
                        //Button To Find User Token
                        Button(action: {}) {
                            Text("Find Token")
                        }
                        .padding(.trailing)
                        //Button To Find Database URL
                        Button(action: {}) {
                            Text("Find Database URL")
                        }
                    }
                    .padding(.bottom)
                    //Button To Save Database Settings
                    Button(action: {}) {
                        Text("Save Database Settings")
                    }
                    //Button To Export Database Settings
                    Button(action: {}) {
                        Text("Export Database Settings")
                    }
                    //Button To Import Database Settings
                    Button(action: {}) {
                        Text("Import Database Settings")
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        //Set Navigation Bar Title To Notion
        .navigationTitle("Notion")
    }
}

struct DatabaseSettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        DatabaseSettingsView().environmentObject(settingsStore)
    }
}
