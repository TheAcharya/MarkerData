//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import Foundation
import Combine

class ProgressPublisher: ObservableObject {
    let progress: Progress
    private var cancellable: AnyCancellable?
    @Published var message: String = ""
    @Published var showProgress: Bool = false

     init(progress: Progress) {
         self.progress = progress
         cancellable = progress.publisher(for: \.fractionCompleted)
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.objectWillChange.send()
             }
     }
    
    func updateProgressTo(progressMessage: String, percentageCompleted: Int) {
        DispatchQueue.main.async {
            self.progress.completedUnitCount = Int64(percentageCompleted)
            self.message = progressMessage
        }
    }
    
    func markasFailed(errorMessage: String) {
        DispatchQueue.main.async {
            self.message = errorMessage
        }
    }

     deinit {
         cancellable?.cancel()
     }
}

