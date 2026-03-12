//
//  HelpButton.swift
//  Marker Data
//
//  Created by Milán Várady on 2026. 03. 12..
//

import SwiftUI

struct HelpButton: View {
    let url: URL

    var body: some View {
        Link(destination: url) {
            HelpButtonImage()
        }
        .buttonStyle(.plain)
    }
}

struct HelpActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HelpButtonImage()
        }
        .buttonStyle(.plain)
    }
}

struct HelpButtonImage: View {
    var body: some View {
        Image(systemName: "questionmark")
            .font(.system(size: 12, weight: .semibold))
            .frame(width: 22, height: 22)
            .background(Color(nsColor: .controlColor))
            .clipShape(Circle())
            .shadow(radius: 1, y: 0.5)
    }
}

#Preview {
    HelpButton(url: URL(string: "https://example.com/")!)
        .padding(50)
}
