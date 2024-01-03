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
                
            TableColumn("Error Type", value: \.exitStatus.rawValue)
            
            TableColumn("Error Message", value: \.errorMessage)
        }
    }
}

#Preview {
    let failedExtractions: [ExtractionFailure] = [
        ExtractionFailure(url: URL(string: "/folder/file1")!, exitStatus: .failedToExtract, errorMessage: "No export destination selected"),
        ExtractionFailure(url: URL(string: "/folder/file2")!, exitStatus: .failedToExtract, errorMessage: "Unexpected number of bananas"),
        ExtractionFailure(url: URL(string: "/folde2/file1")!, exitStatus: .failedToUpload, errorMessage: "Unkown error"),
        ExtractionFailure(url: URL(string: "/folde2/file2")!, exitStatus: .failedToUpload, errorMessage: "Couldn't locate ur mom"),
    ]
    
    return FailedExtractionsView(failedExtractions: failedExtractions)
        .preferredColorScheme(.dark)
}
