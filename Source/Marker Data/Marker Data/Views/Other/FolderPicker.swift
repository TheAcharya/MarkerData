//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers
import Combine

struct FolderPicker: View {
    @EnvironmentObject var settings: SettingsContainer

    static let coordinateSpace = "folderPicker"

    @State private var rect = NSRect.zero

    @Binding var url: URL?

    let title: String

    var urlString: String {
        self.url?.path ?? ""
    }

    var isDragging: Bool {
        settings.folderPickerDropDelegate.isDragging
    }

    var body: some View {
        HStack {
            ZStack {
                
                HStack(spacing: 0) {
                    
                    FolderPickerTextViewRepresentable(
                        url: $url
                    )
                    
                    Image(systemName: "folder.fill")
                        .padding(.trailing, 3)
                    
                }
                
                RoundedRectangle(cornerRadius: 3)
                    .inset(by: -3)
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: presentPanel)
                
            }
            .padding(3)
            .frame(width: 200, height: 20)
            .background(Color.gray)
            .cornerRadius(5)
            .help(urlString)
            .overlay {
                if isDragging {
                    RoundedRectangle(cornerRadius: 5)
                        .inset(by: -2.5)
                        .strokeBorder(
                            Color.accentColor.opacity(0.5),
                            lineWidth: 3
                        )
                }
            }
            .onDrop(
                of: FolderPickerDropDelegate.allowedTypes,
                delegate: settings.folderPickerDropDelegate
            )
            .onReceive(
                settings.folderPickerDropDelegate.droppedURLSubject
            ) { url in
                self.url = url
            }
            
            Button {
                url = URL(string: "")
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
        }
        .formControlLeadingAlignmentGuide()
    }

    func presentPanel() {

        print("FolderPicker.presentPanel")

        if let url = self.settings.store.exportFolderURL {
            self.settings.exportDestinationOpenPanel.directoryURL = url
        }

        self.settings.exportDestinationOpenPanel.begin { response in
            if response == .OK {
                self.url = self.settings.exportDestinationOpenPanel.url
            }
            else {
                print(
                    """
                    FolderPickerRepresentable: NSOpenPanel response: \
                    \(response)
                    """
                )
            }
        }

    }

}

struct FolderPickerTextViewRepresentable: NSViewRepresentable {

    static let placeholderText = "Choose a Folder…"

    @Binding var url: URL?

    let textView: NSTextView

    init(
        url: Binding<URL?>
    ) {
        self._url = url
        self.textView = NSTextView()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, textView: self.textView)
    }

    func makeNSView(context: Context) -> NSTextView {

        self.textView.textContainer?.replaceLayoutManager(MyLayoutManager())
        self.textView.delegate = context.coordinator
        self.textView.drawsBackground = false
        self.textView.isEditable = false
        self.textView.isFieldEditor = false
        self.textView.textContainer?.maximumNumberOfLines = 1

        self.textView.textContainer?.lineBreakMode = .byTruncatingTail

        if let url = self.url {
            self.textView.string = url.path
        }
        else {
            self.textView.string = Self.placeholderText
        }

        context.coordinator.drawCustomGlyphs()

        return self.textView
    }

    func updateNSView(_ textView: NSTextView, context: Context) {

        if let url = self.url {
            textView.string = url.path

            // var range = NSRange()
            // range.location = 0
            // range.length = url.path.count - 1

        }
        else {
            textView.string = Self.placeholderText
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {

        let parent: FolderPickerTextViewRepresentable
        let textView: NSTextView

        init(
            _ parent: FolderPickerTextViewRepresentable,
            textView: NSTextView
        ) {
            self.parent = parent
            self.textView = textView
        }

        func drawCustomGlyphs() {

        }

    }

}

class FolderPickerDropDelegate: ObservableObject, DropDelegate {

    static let allowedTypes: [UTType] = [
        .url, .aliasFile, .text
    ]

    /// Types for which it is known at compile time that all values thereof
    /// are allowed
    static var staticallyAllowedTypes: [UTType] {
        Self.allowedTypes.filter { type in
            type != .text
        }
    }

    @Published var isDragging = false

    let droppedURLSubject = PassthroughSubject<URL, Never>()

    func dropEntered(info: DropInfo) {
        print("dropEntered")
        self.isDragging = true
    }

    func dropExited(info: DropInfo) {
        print("dropExited")
        self.isDragging = false

    }

    // func dropUpdated(info: DropInfo) -> DropProposal? {
    //
    // }

    func validateDrop(info: DropInfo) -> Bool {

        let result = info.hasItemsConforming(
            to: Self.allowedTypes
        )

        print("validateDrop: \(result)")

        return result

    }

    func performDrop(info: DropInfo) -> Bool {

        if let urlProvider = info.itemProviders(for: [.url]).first(
            where: { $0.canLoadObject(ofClass: URL.self) }
        ) {

            let _ = urlProvider.loadObject(
                ofClass: URL.self
            ) { url, error in
                if let url = url {
                    DispatchQueue.main.async {
                        self.droppedURLSubject.send(url)
                    }
                }
                else if let error = error {
                    print("performDrop error: \(error)")
                }
                else {
                    print("url and error are nil")
                }
            }

            return true

        }
        else if let textProvider = info.itemProviders(for: [.text]).first(
            where: { $0.canLoadObject(ofClass: String.self) }
        ) {

            let _ = textProvider.loadObject(
                ofClass: String.self
            ) { string, error in
                if let string = string {

                    let url = URL(fileURLWithPath: string)

                    DispatchQueue.main.async {
                        self.droppedURLSubject.send(url)
                    }

                }
                else if let error = error {
                    print("performDrop error: \(error)")
                }
                else {
                    print("url and error are nil")
                }
            }

            return true

        }
        else {
            return false
        }

    }

}

class MyLayoutManager: NSLayoutManager {

    // override func drawGlyphs(
    //     forGlyphRange glyphsToShow: NSRange,
    //     at origin: NSPoint
    // ) {
    //     super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    // }

}
