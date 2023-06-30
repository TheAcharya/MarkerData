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

    static let coordinateSpace = "folderPicker"

    @EnvironmentObject var settingsStore: SettingsStore

    @State private var rect = NSRect.zero

    @Binding var url: URL?

    let title: String


    var urlString: String {
        self.url?.path ?? ""
    }

    var isDragging: Bool {
        // true
        settingsStore.folderPickerDropDelegate.isDragging
    }

    var body: some View {
        HStack {

            Text("Destination:")
                .fixedSize(horizontal: true, vertical: false)


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
                    .strokeBorder(
                        isDragging ? Color.accentColor : .clear,
                        lineWidth: 2
                    )
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: presentPanel)

            }
            .padding(3)
            .frame(width: 200, height: 20)
            .background(Color.gray)
            .cornerRadius(5)
            .help(urlString)
            .formControlLeadingAlignmentGuide()
            .onDrop(
                of: FolderPickerDropDelegate.allowedTypes,
                delegate: settingsStore.folderPickerDropDelegate
            )
            .onReceive(
                settingsStore.folderPickerDropDelegate.droppedURLSubject
            ) { url in
                self.url = url
            }


        }
    }

    func presentPanel() {

        print("FolderPicker.presentPanel")

        self.settingsStore.exportDestinationOpenPanel.begin { response in
            if response == .OK {
                self.url = self.settingsStore.exportDestinationOpenPanel.url
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
            context.coordinator.drawCustomGlyphs()
        }

        return self.textView
    }

    func updateNSView(_ textView: NSTextView, context: Context) {

        if let url = self.url {

            textView.string = url.path

            var range = NSRange()
            range.location = 0
            range.length = url.path.count - 1



        }
        else {
            textView.string = ""
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
        .url, .aliasFile
    ]

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

        let progress = info.itemProviders(for: [.url]).first(
            where: { $0.canLoadObject(ofClass: URL.self) }
        )?
            .loadObject(ofClass: URL.self, completionHandler: { url, error in
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
            })

        print("performDrop:", progress ?? "nil")

        return progress != nil
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
