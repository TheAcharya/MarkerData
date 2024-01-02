//
//  ExportProcess.swift
//  Marker Data
//
//  Created by Milán Várady on 05/12/2023.
//

import Foundation
import Combine

class ExportProcess {
    var progress: Progress
    var url: URL
    var isFinished: Bool = false
    
    init(url: URL) {
        self.url = url
        self.progress = Progress(totalUnitCount: 100)
    }
}
