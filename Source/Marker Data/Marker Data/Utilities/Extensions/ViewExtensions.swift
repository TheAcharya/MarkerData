//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }

    func modify<Content: View>(
        @ViewBuilder _ content: (Self) -> Content
    ) -> some View {
        content(self)
    }

    func overlayHelpButton(url: URL) -> some View {
        self.modifier(OverlayHelpButton(url: url))
    }

    /**

     ```
     self.alignmentGuide(.formControlAlignment) { d in
         d[.leading]
     }
     ```
     */
    func formControlLeadingAlignmentGuide() -> some View {
        self.alignmentGuide(.formControlAlignment) { d in
            d[.leading]
        }
    }

    func onHover(isHovering: Binding<Bool>) -> some View {
        self.onHover { hovering in
            isHovering.wrappedValue = hovering
        }
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
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

extension HorizontalAlignment {
    private enum ControlAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[HorizontalAlignment.center]
        }
    }
    static let formControlAlignment = HorizontalAlignment(ControlAlignment.self)
}
