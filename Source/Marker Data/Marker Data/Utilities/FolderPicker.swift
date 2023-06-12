//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import AppKit

struct FolderPicker: NSViewRepresentable {
    @Binding var folderURL: URL?
    var buttonTitle: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: FolderPicker
        
        init(_ parent: FolderPicker) {
            self.parent = parent
        }
        
        @objc func openFolderPicker() {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
            
            panel.begin { response in
                if response == .OK {
                    self.parent.folderURL = panel.urls[0]
                }
            }
        }
    }
    
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: buttonTitle, target: context.coordinator, action: #selector(Coordinator.openFolderPicker))
        return button
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) {
        nsView.title = buttonTitle
    }
}
