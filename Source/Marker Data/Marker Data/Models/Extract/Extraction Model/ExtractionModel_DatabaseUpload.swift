//
//  ExtractionModel_DatabaseUpload.swift
//  Marker Data
//
//  Created by Milán Várady on 06/02/2024.
//

import Foundation

extension ExtractionModel {
    func uploadToDatabase(url: URL, databaseProfile: DatabaseProfileModel) async throws {
        func uploadToNotion(notionProfile: NotionDBModel) async throws {
            guard let csv2notionURL = Bundle.main.url(forResource: "csv2notion_neo", withExtension: nil) else {
                Self.logger.error("Failed to upload to Notion: csv2notion executable not found")
                throw DatabaseUploadError.csv2notionExecutableNotFound
            }
            
            let executablePath = csv2notionURL.path(percentEncoded: false).quoted
            
            let logPath = URL.logsFolder
                .appendingPathComponent("csv2notion-neo_log.txt", conformingTo: .plainText).path(percentEncoded: false)
            
            var arguments: [String] = [
                "--workspace", notionProfile.workspaceName.quoted,
                "--token", notionProfile.token.quoted,
                "--image-column", "Image Filename".quoted,
                "--image-column-keep",
                "--mandatory-column", "Marker ID".quoted,
                "--payload-key-column", "Marker ID".quoted,
                "--icon-column", "Icon Image".quoted,
                "--max-threads", "5",
                "--log", logPath.quoted,
                (url.path(percentEncoded: false)).quoted
            ]
            
            // Add database url if defined
            if !notionProfile.databaseURL.isEmpty {
                arguments.insert(contentsOf: ["--url", notionProfile.databaseURL.quoted, "--merge"], at: 2)
            }
            
            // Add rename key column if defined
            if !notionProfile.renameKeyColumn.isEmpty {
                arguments.append(contentsOf: ["--rename-notion-key-column", "Marker ID".quoted, notionProfile.renameKeyColumn.quoted])
            }
            
            let command = "\(executablePath) \(arguments.joined(separator: " "))"
            
            let shellOutputStream = ShellOutputStream()
            
            self.uploadProcesses.append(shellOutputStream.task)
            
            let percentRegex = /([0-9]+)%/
            
            // Update progress
            let cancellable = shellOutputStream.outputPublisher.sink(receiveValue: { output in
                if let match = output.firstMatch(of: percentRegex),
                   let percent = match.1.int {
                    Task {
                        await self.uploadProgress.updateProgress(of: url, to: Int64(percent))
                    }
                }
            })
            
            let result = await shellOutputStream.run(command)
            
            cancellable.cancel()
            
            if result.didFail {
                // Failure
                if Task.isCancelled {
                    Self.logger.error("Upload to Notion cancelled by user.")
                    throw DatabaseUploadError.userCancel
                } else {
                    Self.logger.error("Failed to upload to Notion.\nOutput: \(result.output)")
                    throw DatabaseUploadError.notionUploadError
                }
            } else {
                // Success
                await self.uploadProgress.markProcessAsFinished(url: url)
            }
        }
        
        switch databaseProfile.plaform {
        case .notion:
            guard let notionProfile = databaseProfile as? NotionDBModel else {
                throw DatabaseUploadError.failedToUnwrapAsNotionProfile
            }
            
            try await uploadToNotion(notionProfile: notionProfile)
        case .airtable:
            break
        }
    }
}
