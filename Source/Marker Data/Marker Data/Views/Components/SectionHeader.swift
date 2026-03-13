//
//  SectionHeader.swift
//  Marker Data
//
//  Created by Milán Várady on 2026. 03. 13..
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var systemImage: String? = nil
    
    init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.accent)
            }
            Text(title)
                .font(.headline)
        }
        .padding(.top, 8)
    }
}

#Preview {
    SectionHeader("Test header")
}
