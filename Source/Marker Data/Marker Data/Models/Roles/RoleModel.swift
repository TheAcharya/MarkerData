//
//  RoleModel.swift
//  Marker Data
//
//  Created by Milán Várady on 27/01/2024.
//

import Foundation
import DAWFileKit

struct RoleModel: Identifiable, Codable, Hashable, Equatable {
    let role: FinalCutPro.FCPXML.AnyRole
    var enabled: Bool
    
    var id: String {
        return self.role.rawValue
    }

    var displayName: String {
        var name = self.role.rawValue

        if let captionRole = FinalCutPro.FCPXML.CaptionRole(rawValue: self.role.rawValue) {
            name = "\(captionRole.role) (\(captionRole.captionFormat))"
        }

        return name
    }
}
