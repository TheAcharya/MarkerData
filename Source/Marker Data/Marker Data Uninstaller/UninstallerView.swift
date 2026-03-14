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

    var body: some View {
        VStack(spacing: 18) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 96, height: 96)

            Text("Uninstall Marker Data")
                .font(.title2.weight(.semibold))

            Text("Completely remove Marker Data, including all Caches, Preferences, Configurations and Databases.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 420)

            HStack(spacing: 12) {
                Button("Uninstall Marker Data", role: .destructive) {
                    runUninstall()
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
                        Label("Marker Data has been successfully uninstalled. Log file created on Desktop.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Uninstall finished with some issues. Log file created on Desktop.", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(uninstallIssues.joined(separator: "\n"))
                                .font(.caption)
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
