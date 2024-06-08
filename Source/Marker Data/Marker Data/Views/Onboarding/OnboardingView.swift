//
//  OnboardingView.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import SwiftUI

struct OnboardingView: View {
    @State var currentPage: Int = 0
    let lastPage = onboardingPages.count - 1

    @AppStorage("showOnboarding") var showOnboarding = true

    var body: some View {
        VStack {
            if let onboardingPage = onboardingPages[safe: currentPage] {
                onboardingPage
                    .frame(maxWidth: 500)
                    .padding(.top)
            }

            Spacer()

            buttonsView
                .padding(.bottom)
        }
        .frame(width: 600, height: 370)
    }

    var buttonsView: some View {
        HStack {
            if currentPage != lastPage {
                Button("Close") {
                    showOnboarding = false
                }
                .buttonStyle(BigButtonStyle(color: .secondary))

                Button("Next") {
                    withAnimation {
                        currentPage = min(currentPage + 1, lastPage)
                    }
                }
                .buttonStyle(BigButtonStyle(color: .accent, minWidth: 120))
            } else {
                Button("Done") {
                    showOnboarding = false
                }
                .buttonStyle(BigButtonStyle(color: .accent, minWidth: 180))
            }
        }
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
