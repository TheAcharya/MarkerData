//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI

extension View {
    func overlayHelpButton(url: URL) -> some View {
        self.modifier(OverlayHelpButton(url: url))
    }
}

struct OverlayHelpButton: ViewModifier {
    @Environment(\.openURL) var openURL

    let url: URL

    func body(content: Content) -> some View {
        content
            .frame(maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing) {
                HelpButton {
                    self.openURL(url)
                }
                .padding([.trailing, .bottom], 10)
            }
    }
}

