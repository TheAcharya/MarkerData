//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import Foundation

let exportFolderPathKey = "exportFolderPath"
extension UserDefaults {
    
    var exportFolder: URL {
        get {
            if let exportFolderPathString = self.value(forKey: exportFolderPathKey) as? String  {
                return  URL(fileURLWithPath: exportFolderPathString)
            } else {
                if let moviesFolderURL = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first {
                    // Create MarkerData folder
                    print("movies Folder = \(moviesFolderURL.absoluteString)")
                    let markerDataFolderURL = moviesFolderURL.appendingPathComponent("Marker Data")
                    do {
                        try FileManager.default.createDirectory(at: markerDataFolderURL, withIntermediateDirectories: true, attributes: nil)
                        return markerDataFolderURL
                    } catch {
                        print("can not create default Marker Default Folder, revert to tmp folder.")
                    }
                }
            }
            return FileManager.default.temporaryDirectory
        }
    }
    

}
