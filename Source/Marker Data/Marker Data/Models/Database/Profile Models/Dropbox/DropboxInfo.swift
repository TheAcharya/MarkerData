//
//  DropboxInfo.swift
//  Marker Data
//
//  Created by Milán Várady on 08/02/2024.
//

import Foundation

struct DropboxInfo: Codable {
    let appKey: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case appKey = "app_key"
        case refreshToken = "refresh_token"
    }
}
