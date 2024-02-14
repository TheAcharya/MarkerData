//
//  QueueInstance.swift
//  Marker Data
//
//  Created by Milán Várady on 14/02/2024.
//

import Foundation

class QueueInstance: ObservableObject, Identifiable {
    public let name: String
    let extractInfo: ExtractInfo
    let uploader = DatabaseUploader()
    let availableDatabaseProfiles: [DatabaseProfileModel]
    @Published var uploadDestination: DatabaseProfileModel? = nil
    
    var creationDateFormatted: String {
        extractInfo.creationDate.formatted()
    }
    
    init(extractInfo: ExtractInfo, databaseProfiles: [DatabaseProfileModel]) {
        self.name = extractInfo.jsonURL.deletingPathExtension().lastPathComponent
        self.extractInfo = extractInfo
        self.availableDatabaseProfiles = databaseProfiles.filter { $0.plaform == extractInfo.profile }
    }
}
