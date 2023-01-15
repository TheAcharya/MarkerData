//
//  DatabasePreferences.swift
//  Marker Data
//
//  Created by Mark Howard on 15/01/2023.
//

import SwiftUI

//Database Preferences View
struct DatabasePreferences: View {
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView {
                List {
                    NavigationLink(destination: notion) {
                        Label("Notion", systemImage: "plus")
                    }
                }
                .listStyle(.sidebar)
            } detail: {
                Text("Database Preferences")
            }
            .frame(width: 700, height: 400)
        } else if #available(macOS 12.0, *) {
            // Fallback On macOS 12
            NavigationView {
                List {
                    NavigationLink(destination: notion) {
                        Label("Notion", systemImage: "plus")
                    }
                }
                .listStyle(.sidebar)
                VStack {
                    Text("Database Preferences")
                }
            }
            .frame(width: 700, height: 400)
        } else if #available(macOS 11.0, *) {
            //Fallback On macOS 11
            NavigationView {
                List {
                    NavigationLink(destination: notion) {
                        Label("Notion", systemImage: "plus")
                    }
                }
                .listStyle(.sidebar)
                VStack {
                    Text("Database Preferences")
                }
            }
            .frame(width: 700, height: 400)
        }
    }
    var notion: some View {
        Text("Notion")
    }
}

struct DatabasePreferences_Previews: PreviewProvider {
    static var previews: some View {
        DatabasePreferences()
    }
}
