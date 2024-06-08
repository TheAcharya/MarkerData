//
//  BigButtonStyle.swift
//  Marker Data
//
//  Created by Milán Várady on 08/06/2024.
//

import SwiftUI

struct BigButtonStyle: ButtonStyle {
    var color: Color
    var minWidth: CGFloat = 0

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: minWidth)
            .padding(8)
            .font(.system(size: 18, weight: .semibold))
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0) // Optional: Add a scale effect for press feedback
            .animation(.spring(), value: configuration.isPressed) // Optional: Animate the scale effect
    }
}
