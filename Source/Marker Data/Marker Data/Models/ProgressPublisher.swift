//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import Foundation
import Combine

class ProgressPublisher: ObservableObject {
    /// Progress from 0 to 100
    let progress: Progress
    private var cancellable: AnyCancellable?
    @Published var message: String = ""
    @Published var icon: String = ""
    @Published var showProgress: Bool = false

     init() {
         self.progress = Progress(totalUnitCount: 100)
         
         cancellable = progress.publisher(for: \.fractionCompleted)
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.objectWillChange.send()
             }
     }
    
    func updateProgressTo(progressMessage: String, percentageCompleted: Int, icon: String = "") {
        DispatchQueue.main.async {
            self.progress.completedUnitCount = Int64(percentageCompleted)
            self.message = progressMessage
            self.icon = icon
        }
    }
    
    func markasFailed(errorMessage: String) {
        DispatchQueue.main.async {
            self.message = errorMessage
            self.icon = "xmark"
            self.progress.cancel()
        }
    }

     deinit {
         cancellable?.cancel()
     }
}


