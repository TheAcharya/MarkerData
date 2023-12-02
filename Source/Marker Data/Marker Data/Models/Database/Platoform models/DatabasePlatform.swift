//
//  DatabasePlatform.swift
//  Marker Data
//
//  Created by Milán Várady on 22/11/2023.
//

import Foundation

enum DatabasePlatform: String, Codable, CaseIterable, Identifiable {
    case notion = "Notion"
    case airtable = "Airtable"
    
    var id: Self { self }
}
