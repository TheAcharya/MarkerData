//
//  QueueInstance.swift
//  Marker Data
//
//  Created by Milán Várady on 14/02/2024.
//

import Foundation
import OSLog

class QueueInstance: ObservableObject, Identifiable {
    public let name: String
    private let folderURL: URL
    let extractInfo: ExtractInfo
    let uploader = DatabaseUploader()
    let availableDatabaseProfiles: [DatabaseProfileModel]
    @MainActor
    @Published var uploadDestination: DatabaseProfileModel? = nil
    @MainActor
    @Published var status: QueueStatus = .idle
    
    var creationDateFormatted: String {
        extractInfo.creationDate.formatted()
    }
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "QueueInstance")
    
    init(extractInfo: ExtractInfo, folderURL: URL, databaseProfiles: [DatabaseProfileModel]) {
        self.name = extractInfo.jsonURL.deletingPathExtension().lastPathComponent
        self.extractInfo = extractInfo
        self.availableDatabaseProfiles = databaseProfiles.filter { $0.plaform == extractInfo.profile }
        self.folderURL = folderURL
        self.uploader.uploadProgress.showDockProgress = false
    }
    
    public func upload() async throws {
        guard let uploadDestinationUnwrapped = await self.uploadDestination else {
            return
        }
        
        await MainActor.run {
            self.status = .uploading
        }
        
        try await self.uploader.uploadToDatabase(
            url: extractInfo.jsonURL,
            databaseProfile: uploadDestinationUnwrapped
        )
        
        await MainActor.run {
            self.status = .success
        }
    }
    
    public func deleteFolder() {
        do {
            try self.folderURL.trashOrDelete()
        } catch {
            Self.logger.error("Failed to delete folder after queue upload: \(self.folderURL.path(percentEncoded: false))")
        }
    }
}
