//
//  NotificationFrequency.swift
//  Marker Data
//
//  Created by Milán Várady on 21/01/2024.
//

import Foundation

enum NotificationFrequency: Int, CaseIterable, Identifiable {
    case never = 0
    case onlyOnCompletion = 1
    case allSteps = 2
    
    var displayName: String {
        switch self {
        case .never:
            "Never"
        case .onlyOnCompletion:
            "Only on Completion"
        case .allSteps:
            "All Steps"
        }
    }
    
    var id: Int {
        self.rawValue
    }
}
