//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import Combine

class ErrorViewModel: ObservableObject {
    @Published var errorMessage: String? {
        didSet {
            showAlert = errorMessage != nil
        }
    }
    
    @Published private(set) var showAlert = false
    
    private let scheduler: DispatchQueue
    
    init(scheduler: DispatchQueue = DispatchQueue.main) {
        self.scheduler = scheduler
        _ = $errorMessage
            .receive(on: scheduler)
            .sink { [weak self] _ in
                self?.showAlert = self?.errorMessage != nil
            }
    }
    
    func dismissAlert() {
        showAlert = false
        errorMessage = nil
    }
}


