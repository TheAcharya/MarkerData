//
//  OnboardingPageView.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let features: [OnboardingFeature]

    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .padding(.bottom, 20)

            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { feature in
                    featureView(feature)
                }
            }
        }
    }

    func featureView(_ feature: OnboardingFeature) -> some View {
        HStack {
            Image(systemName: feature.icon)
                .foregroundStyle(.accent)
                .font(.system(size: 24))

            VStack(alignment: .leading) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .bold))

                Text(feature.description)
                    .fontWeight(.light)
            }
        }
    }
}

#Preview {
    OnboardingPageView(
        title: "Features of Marker Data",
        features: [
            .init(
                icon: "puzzlepiece.extension",
                title: "Integration with Final Cut Pro",
                description: "Integrates with Final Cut Pro, boasting a native Share Destination & Workflow Extension."
            ),
            .init(
                icon: "briefcase",
                title: "Configurations",
                description: "Allows the creation of multiple configurations tailored to diverse project requirements."
            ),
            .init(
                icon: "server.rack",
                title: "Databases",
                description: "Native integration with renowned databases such as Airtable and Notion."
            )
        ]
    )
    .preferredColorScheme(.dark)
    .padding()
}
