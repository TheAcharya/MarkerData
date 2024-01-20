//
//  AppCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import Foundation
import SwiftUI

struct AppCommands: Commands {
    @Binding var sidebarSelection: MainViews
    
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About Marker Data") {
                sidebarSelection = .about
            }
        }
    }
}
