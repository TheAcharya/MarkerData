//
//  OnboardingFeature.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import Foundation

struct OnboardingFeature: Identifiable {
    let icon: String
    let title: String
    let description: String

    var id: String {
        self.icon + self.title + self.description
    }
}
