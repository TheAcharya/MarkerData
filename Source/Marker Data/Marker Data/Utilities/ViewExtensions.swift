import SwiftUI

extension View {
    
    func modify<Content: View>(
        @ViewBuilder _ content: (Self) -> Content
    ) -> some View {
        content(self)
    }

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

extension Scene {
    
    func modify<Content: Scene>(
        @SceneBuilder _ content: (Self) -> Content
    ) -> some Scene {
        content(self)
    }

}
