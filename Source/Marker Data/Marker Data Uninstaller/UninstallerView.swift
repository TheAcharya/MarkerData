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
        ZStack {
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.18),
                    Color.primary.opacity(0.06),
                    Color.indigo.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                HStack(spacing: 12) {
                    let uninstallDisabled = isUninstalling || hasRunUninstall
                    Button("Uninstall Marker Data", role: .destructive) {
                        isShowingUninstallConfirmation = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .foregroundStyle(.white)
                    .opacity(uninstallDisabled ? 0.85 : 1)
                    .allowsHitTesting(!uninstallDisabled)

                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .foregroundStyle(.white)
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
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 22, x: 0, y: 10)
            .padding(18)
        }
        .frame(width: 520, height: 340)
        .tint(.indigo)
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
