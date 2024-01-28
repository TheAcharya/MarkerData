//
//  RoleExtension.swift
//  Marker Data
//
//  Created by Milán Várady on 25/01/2024.
//

import Foundation
import DAWFileKit

extension FinalCutPro.FCPXML.AnyRole: Identifiable, Codable {
    public var id: String {
        self.role
    }
}
