//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import Foundation
import Combine

class FolderURLModel: ObservableObject {
    @Published var folderURL: URL? {
        didSet {
            if let url = folderURL {
                saveFolderPathToUserDefaults(folderURL: url)
            }
        }
    }
    
    private let userDefaultsKey: String
    
    init(userDefaultsKey: String) {
        self.userDefaultsKey = userDefaultsKey
        folderURL = getFolderPathFromUserDefaults()
    }
    
    private func saveFolderPathToUserDefaults(folderURL: URL) {
        UserDefaults.standard.set(folderURL.path, forKey: userDefaultsKey)
        
    }
    
    private func getFolderPathFromUserDefaults() -> URL? {
        if let savedPath = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return URL(fileURLWithPath: savedPath)
        }
        return URL(fileURLWithPath: "~/")
    }
}

