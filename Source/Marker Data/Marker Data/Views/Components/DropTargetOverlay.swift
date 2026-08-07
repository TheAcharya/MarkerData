//
//  DropTargetOverlay.swift
//  Marker Data
//
//  Created by Vigneswaran Rajkumar
//
//
//  Visual overlay shown while dragging a supported drop over Extract or Roles.
//

import SwiftUI

struct DropTargetOverlay: View {
    var message: String = "Drop to Extract Marker Metadata"
    var subtitle: String? = "Use Marker Data's Share Destination for Image Extraction"
    var systemImage: String = "arrow.down.doc.fill"

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)

            VStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(Color.heroGradient)
                    .symbolEffect(.bounce, options: .repeating)

                VStack(spacing: 6) {
                    Text(message)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.85), lineWidth: 2)
                .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
    }
}

#Preview {
    DropTargetOverlay()
        .frame(width: 500, height: 320)
        .preferredColorScheme(.dark)
}
