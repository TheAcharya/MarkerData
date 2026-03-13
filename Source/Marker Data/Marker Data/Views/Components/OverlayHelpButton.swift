//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI

extension View {
    func overlayHelpButton(url: URL) -> some View {
        self.overlay(alignment: .bottomTrailing) {
            HelpButton(url: url)
                .padding([.trailing, .bottom], 16)
        }
    }
}
