//
//  UninstallerView.swift
//  Marker Data Uninstaller
//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import SwiftUI

struct UninstallerView: View {
    @State private var isUninstalling = false
    @State private var hasRunUninstall = false
    @State private var uninstallIssues: [String] = []
    @State private var isShowingUninstallConfirmation = false

    private var uninstallDisabled: Bool { isUninstalling || hasRunUninstall }

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
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 420)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                HStack(spacing: 12) {
                    Button("Uninstall Marker Data", role: .destructive) {
                        isShowingUninstallConfirmation = true
                    }
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
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .foregroundStyle(.white)
                    .disabled(uninstallDisabled)

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
                    VStack(spacing: 6) {
                        Label(
                            uninstallIssues.isEmpty
                                ? "Marker Data has been successfully uninstalled."
                                : "Uninstall finished.",
                            systemImage: "checkmark.circle.fill"
                        )
                        .foregroundStyle(.green)

                        Text(uninstallIssues.isEmpty ? "Log file created on Desktop." : "Check log for details.")
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 440)
                }
            }
            .padding(24)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.18), radius: 22, x: 0, y: 10)
            .padding(18)
        }
        .frame(width: 520, height: 340)
        .tint(.indigo)
    }

    private func runUninstall() {
        isUninstalling = true
        hasRunUninstall = false
        uninstallIssues = []

        Task {
            let issues = await Task.detached(priority: .userInitiated) {
                MarkerDataUninstaller.run()
            }.value

            uninstallIssues = issues
            isUninstalling = false
            hasRunUninstall = true
        }
    }
}

#Preview {
    UninstallerView()
}
