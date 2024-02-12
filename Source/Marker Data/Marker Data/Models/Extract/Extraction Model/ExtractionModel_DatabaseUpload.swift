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
            
            let logPath = URL.logsFolder
                .appendingPathComponent("csv2notion-neo_log.txt", conformingTo: .plainText)
            
            var argumentList = ShellArgumentList(executablePath: csv2notionURL, parameters: [
                ShellParameter(for: "--workspace", value: notionProfile.workspaceName),
                ShellParameter(for: "--token", value: notionProfile.token),
                ShellParameter(for: "--image-column", value: "Image Filename"),
                ShellFlag("--image-column-keep"),
                ShellParameter(for: "--mandatory-column", value: "Marker ID"),
                ShellParameter(for: "--payload-key-column", value: "Marker ID"),
                ShellParameter(for: "--icon-column", value: "Icon Image"),
                ShellParameter(for: "--max-threads", value: "5"),
                ShellParameter(for: "--log", url: logPath),
                ShellArgument(url: url)
            ])
            
            // Add database url if defined
            if !notionProfile.databaseURL.isEmpty {
                argumentList.append(ShellParameter(for: "--url", value: notionProfile.databaseURL))
                argumentList.append(ShellFlag("--merge"))
            }
            
            // Add rename key column if defined
            if !notionProfile.renameKeyColumn.isEmpty {
                argumentList.append(ShellRawArgument("--rename-notion-key-column \"Marker ID\" \(notionProfile.renameKeyColumn.quoted)"))
            }
            
            // Add merge only columns
            for column in notionProfile.mergeOnlyColumns {
                argumentList.append(ShellParameter(for: "--merge-only-column", value: column.rawValue))
            }
            
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
            
            let result = await shellOutputStream.run(argumentList.getCommand())
            
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
        
        func uploadToAirtable(airtableProfile: AirtableDBModel) async throws {
            guard let airliftURL = Bundle.main.url(forResource: "airlift", withExtension: nil) else {
                Self.logger.error("Failed to upload to Airtable: airlift executable not found")
                throw DatabaseUploadError.csv2notionExecutableNotFound
            }
            
            let logPath = URL.logsFolder
                .appendingPathComponent("airlift_log.txt", conformingTo: .plainText)
            
            var argumentList = ShellArgumentList(executablePath: airliftURL, parameters: [
                ShellParameter(for: "--token", value: airtableProfile.token),
                ShellParameter(for: "--base", value: airtableProfile.baseID),
                ShellParameter(for: "--table", value: airtableProfile.tableID),
                ShellParameter(for: "--dropbox-token", url: URL.dropboxTokenJSON),
                ShellRawArgument(#"--attachment-columns-map "Image Filename" "Attachments""#),
                ShellFlag("--md"),
                ShellParameter(for: "--log", url: logPath),
                ShellFlag("--verbose"),
                ShellArgument(url: url)
            ])
            
            // Add rename key column if defined
            if !airtableProfile.renameKeyColumn.isEmpty {
                argumentList.append(ShellRawArgument("--rename-notion-key-column \"Marker ID\" \(airtableProfile.renameKeyColumn.quoted)"))
            }
            
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
            
            let result = await shellOutputStream.run(argumentList.getCommand())
            
            cancellable.cancel()
            
            if result.didFail {
                // Failure
                if Task.isCancelled {
                    Self.logger.error("Upload to Airtable cancelled by user.")
                    throw DatabaseUploadError.userCancel
                } else {
                    Self.logger.error("Failed to upload to Airtable.\nOutput: \(result.output)")
                    throw DatabaseUploadError.airtableUploadError
                }
            } else {
                // Success
                await self.uploadProgress.markProcessAsFinished(url: url)
            }
        }
        
        switch databaseProfile.plaform {
        case .notion:
            guard let notionProfile = databaseProfile as? NotionDBModel else {
                throw DatabaseUploadError.failedToUnwrapDBProfile
            }
            
            try await uploadToNotion(notionProfile: notionProfile)
        case .airtable:
            guard let airtableProfile = databaseProfile as? AirtableDBModel else {
                throw DatabaseUploadError.failedToUnwrapDBProfile
            }
            
            try await uploadToAirtable(airtableProfile: airtableProfile)
        }
    }
}
