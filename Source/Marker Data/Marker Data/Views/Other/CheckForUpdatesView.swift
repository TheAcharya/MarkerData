//
//  CheckForUpdatesView.swift
//  Marker Data
//
//  Created by Milán Várady on 29/02/2024.
//

import SwiftUI
import Sparkle

/// This view model class publishes when new updates can be checked by the user
final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

/// A button that opens sparkle updater and checks for available updates
struct CheckForUpdatesView<T: View>: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let updater: SPUUpdater
    let label: ()->T

    init(updater: SPUUpdater, @ViewBuilder label: @escaping ()->T) {
        self.updater = updater

        // Create our view model for our CheckForUpdatesView
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)

        self.label = label
    }

    var body: some View {
        Button(action: updater.checkForUpdates, label: label)
            .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}
