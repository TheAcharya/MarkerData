//
//  PulsingIcon.swift
//  Marker Data
//
//  Created by Milán Várady on 16/01/2024.
//

import SwiftUI

struct PulsingIcon: View {
    let icon: String
    let iconSize: CGFloat
    let tint: Color
    let duration: TimeInterval
    let ringDiameter: CGFloat
    let ringMaxScale: CGFloat
    
    init(
        icon: String,
        iconSize: CGFloat = 32,
        tint: Color = .accentColor,
        duration: TimeInterval = 2,
        ringDiameter: CGFloat = 20,
        ringMaxScale: CGFloat = 4) {
            
        self.icon = icon
        self.iconSize = iconSize
        self.tint = tint
        self.duration = duration
        self.ringDiameter = ringDiameter
        self.ringMaxScale = ringMaxScale
    }
    
    @State private var scale: CGFloat = 1
    @State private var shadowScale: CGFloat = 1
    @State private var opacity: Double = 1
    
    var body: some View {
        ZStack {
            tint
                .opacity(opacity)
                .frame(width: self.ringDiameter, height: self.ringDiameter)
                .cornerRadius(100)
                .scaleEffect(shadowScale)
                .onAppear {
                    withAnimation(
                        .easeOut(duration: self.duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        shadowScale = self.ringMaxScale
                        opacity = 0
                    }
                }
            
            
            Image(systemName: self.icon)
                .font(.system(size: self.iconSize))
                .symbolRenderingMode(.multicolor)
                .tint(tint)
        }
    }
}

#Preview {
    VStack {
        PulsingIcon(icon: "folder.circle.fill")
    }
    .frame(width: 300, height: 300)
}
