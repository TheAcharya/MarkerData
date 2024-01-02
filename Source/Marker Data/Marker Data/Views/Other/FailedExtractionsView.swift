//
//  FailedExtractionsView.swift
//  Marker Data
//
//  Created by Milán Várady on 02/01/2024.
//

import SwiftUI

struct FailedExtractionsView: View {
    let failedExtractions: [ExtractionFailure]
    
    var body: some View {
        Table(failedExtractions) {
            TableColumn("File Path") { failedTask in
                Text(failedTask.url.path(percentEncoded: false))
            }
                
            TableColumn("Exit Status", value: \.exitStatus.rawValue)
        }
    }
}

#Preview {
    let failedExtractions: [ExtractionFailure] = [
        ExtractionFailure(url: URL(string: "/folder/file1")!, exitStatus: .failedToExtract),
        ExtractionFailure(url: URL(string: "/folder/file2")!, exitStatus: .failedToExtract),
        ExtractionFailure(url: URL(string: "/folde2/file1")!, exitStatus: .failedToUpload),
        ExtractionFailure(url: URL(string: "/folde2/file2")!, exitStatus: .failedToUpload),
    ]
    
    return FailedExtractionsView(failedExtractions: failedExtractions)
}
