//
//  OnboardingView.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import SwiftUI

struct OnboardingView: View {
    @State var currentPage: Int = 0
    let totalPages = onboardingPages.count
    let lastPageIndex = onboardingPages.count - 1

    @AppStorage("showOnboarding") var showOnboarding = true

    var body: some View {
        VStack {
            if let onboardingPage = onboardingPages[safe: currentPage] {
                onboardingPage
                    .frame(maxWidth: 600)
                    .padding(.top)
            }

            Spacer()

            pageIndicators
                .padding(.bottom)

            buttonsView
                .padding(.bottom)
        }
        .frame(width: 700, height: 440)
        .overlay(alignment: .topTrailing) {
            closeButton
        }
    }

    var buttonsView: some View {
        HStack {
            // Back button
            Button("Back") {
                withAnimation {
                    currentPage = max(currentPage - 1, 0)
                }
            }
            .buttonStyle(BigButtonStyle(color: .secondary, minWidth: 80))
            .disabled(currentPage == 0)

            // Next and done button
            Group {
                if currentPage != lastPageIndex {
                    Button("Next") {
                        withAnimation {
                            currentPage = min(currentPage + 1, lastPageIndex)
                        }
                    }
                } else {
                    Button("Done") {
                        showOnboarding = false
                    }
                }
            }
            .buttonStyle(BigButtonStyle(color: .accent, minWidth: 80))
        }
    }

    var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentColor : Color.gray)
                    .frame(width: 10, height: 10)
            }
        }
    }

    var closeButton: some View {
        Button {
            showOnboarding = false
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 20))
        }
        .padding()
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
