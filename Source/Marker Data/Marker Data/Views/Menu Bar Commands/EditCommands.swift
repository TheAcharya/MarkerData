//
//  EditCommands.swift
//  Marker Data
//
//  Created by Milán Várady on 13/02/2024.
//

import SwiftUI

struct EditCommands: Commands {
    var body: some Commands {
        // Remove Undo & Redo
        CommandGroup(replacing: .undoRedo) { }
    }
}
