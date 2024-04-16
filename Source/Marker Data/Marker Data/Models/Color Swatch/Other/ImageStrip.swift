//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageStrip: Hashable, Identifiable, ObservableObject {
    
    let id: UUID
    let url: URL
    let ending = ".Strip"
    let imageExtension = "jpg"
    
    lazy var size: CGSize = {
        if let nsImage = nsImage() {
            return CGSize(width: nsImage.size.width, height: nsImage.size.height)
        } else {
            return .zero
        }
    }()
    
    var title: String
    
    var exportTitle: String {
        title
            .appending(ending)
            .appending(".")
            .appending(imageExtension)
    }
    
    var exportURL: URL?
    
    @Published var colors = [Color]()
    @ObservedObject var colorMood: ColorMood
    
    init(url: URL, colors: [Color] = [Color](), exportDirectory: URL? = nil) {
        self.id = UUID()
        self.url = url
        self.colors = colors
        self.exportURL = exportDirectory
        self.colorMood = .init()
        self.title = url.deletingPathExtension().lastPathComponent
    }
    
    func nsImage() -> NSImage? {
        do {
            let data = try Data(contentsOf: url)
            let nsImage = NSImage(data: data)
            return nsImage
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageStrip, rhs: ImageStrip) -> Bool {
        lhs.id == rhs.id
    }
}

extension ImageStrip {
    static var placeholder: ImageStrip {
        let url = Bundle.main.url(forResource: "Placeholder", withExtension: "jpg")!
        
        let imageStrip = ImageStrip(url: url)
        
        imageStrip.colors = [
            Color.black,
            Color.gray,
            Color.white,
            Color.red,
            Color.orange,
            Color.yellow,
            Color.green,
            Color.cyan,
            Color.blue,
            Color.purple
        ]
        
        return imageStrip
    }
}
