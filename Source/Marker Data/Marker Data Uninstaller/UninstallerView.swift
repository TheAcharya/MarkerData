//
//  UninstallerView.swift
//  Marker Data Uninstaller
//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import SwiftUI
import AppKit

struct UninstallerView: View {
    @State private var isUninstalling = false
    @State private var hasRunUninstall = false
    @State private var uninstallIssues: [String] = []
    @State private var isShowingUninstallConfirmation = false

    var body: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 96, height: 96)

            Text("Marker Data Uninstaller")
                .font(.title2.weight(.semibold))

            Text("Completely remove Marker Data, including all Caches, Preferences, Configurations and Databases.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)

            HStack(spacing: 12) {
                Button("Uninstall Marker Data", role: .destructive) {
                    isShowingUninstallConfirmation = true
                }
                .disabled(isUninstalling || hasRunUninstall)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }

            if isUninstalling {
                ProgressView("Uninstalling...")
                    .controlSize(.small)
                    .padding(.top, 6)
            }

            if hasRunUninstall, !isUninstalling {
                Group {
                    if uninstallIssues.isEmpty {
                        VStack(spacing: 6) {
                            Label("Marker Data has been successfully uninstalled.", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Log file created on Desktop.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(spacing: 6) {
                            Label("Uninstall finished.", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Check log for details.")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: 440)
            }
        }
        .padding(24)
        .frame(width: 520, height: 340)
        .confirmationDialog(
            "Uninstall Marker Data?",
            isPresented: $isShowingUninstallConfirmation,
            titleVisibility: .visible
        ) {
            Button("Uninstall Marker Data", role: .destructive) {
                runUninstall()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete Marker Data preferences, caches, configurations, and local databases.")
        }
    }

    private func runUninstall() {
        isUninstalling = true
        hasRunUninstall = false
        uninstallIssues = []

        Task {
            let issues = await Task.detached(priority: .userInitiated) {
                MarkerDataUninstaller.run()
            }.value

            await MainActor.run {
                uninstallIssues = issues
                isUninstalling = false
                hasRunUninstall = true
            }
        }
    }
}

#if DEBUG
#Preview {
    UninstallerView()
}
#endif
