//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct HelpButton: NSViewRepresentable {
    
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .helpButton
        button.title = ""
        context.coordinator.button = button
        return button
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) {
        
    }

    class Coordinator {
        
        let parent: HelpButton
        var button: NSButton? {
            didSet {
                if self.button != nil {
                    self.bindButtonAction()
                }
            }
        }

        init(parent: HelpButton) {
            self.parent = parent
            self.button = nil

        }
        
        func bindButtonAction() {
            self.button!.target = self
            self.button!.action = #selector(self.didPressButton)
        }
        
        @objc func didPressButton() {
            self.parent.action()
        }
        
    }

}

struct HelpButton_Previews: PreviewProvider {
    
    struct Preview: View {
        
        @State private var bool = true
        
        var body: some View {
            VStack {
                HelpButton {
                    bool.toggle()
                }
                Text(verbatim: "\(bool)")
            }
            .padding(20)
            .frame(minWidth: 100, minHeight: 100)
        }
        
    }

    static var previews: some View {
        Preview()
    }
    
}