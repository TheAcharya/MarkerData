//
//  DatabaseUploader.swift
//  Marker Data
//
//  Created by Milán Várady on 06/02/2024.
//

import Foundation
import OSLog

@MainActor
final class DatabaseUploader: ObservableObject {
    @Published var uploadProgress = ProgressViewModel(taskDescription: "Upload")
    
    private var uploadProcesses: [Process?] = []
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DatabaseUploader")
    
    public func uploadToDatabase(url: URL, databaseProfile: DatabaseProfileModel) async throws {
        switch databaseProfile.plaform {
        case .notion:
            guard let notionProfile = databaseProfile as? NotionDBModel else {
                throw DatabaseUploadError.failedToUnwrapDBProfile
            }
            
            // Add process to upload progress
            self.uploadProgress.addProcess(url: url)
            
            try await uploadToNotion(url: url, notionProfile: notionProfile)
        case .airtable:
            guard let airtableProfile = databaseProfile as? AirtableDBModel else {
                throw DatabaseUploadError.failedToUnwrapDBProfile
            }
            
            // Add process to upload progress
            self.uploadProgress.addProcess(url: url)
            
            try await uploadToAirtable(url: url, airtableProfile: airtableProfile)
        }
    }
    
    public func resetProgress() {
        self.uploadProgress.progress.cancel()
        self.uploadProcesses.removeAll()
    }
    
    public func cancelAll() {
        Self.logger.notice("Cancelling upload processes: \(self.uploadProcesses)")
        
        for process in self.uploadProcesses {
            process?.terminate()
        }
    }
    
    // MARK: Platform uploads
    
    private func uploadToNotion(url: URL, notionProfile: NotionDBModel) async throws {
        guard let csv2notionURL = Bundle.main.url(forResource: "csv2notion_neo", withExtension: nil) else {
            Self.logger.error("Failed to upload to Notion: csv2notion executable not found")
            throw DatabaseUploadError.csv2notionExecutableNotFound
        }
        
        let logPath = URL.logsFolder
            .appendingPathComponent("csv2notion-neo_log.txt", conformingTo: .plainText)
        
        var argumentList = ShellArgumentList(executablePath: csv2notionURL, parameters: [
            ShellParameter(for: "--workspace", value: notionProfile.workspaceName),
            ShellParameter(for: "--token", value: notionProfile.token),
            ShellRawArgument(#"--image-column "Image Filename" "Palette Filename""#),
            ShellFlag("--image-column-keep"),
            ShellParameter(for: "--mandatory-column", value: "Marker ID"),
            ShellParameter(for: "--payload-key-column", value: "Marker ID"),
            ShellParameter(for: "--icon-column", value: "Icon Image"),
            ShellParameter(for: "--max-threads", value: "15"),
            ShellParameter(for: "--log", url: logPath),
            ShellFlag("--verbose"),
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
            argumentList.append(ShellParameter(for: "--merge-only-column", value: column.name))
        }
        
        let (task, pipe) = try Shell.createProcess(command: argumentList.getCommand(), pty: false)

        self.uploadProcesses.append(task)

        let percentRegex = /([0-9]+)%/

        var completeOutput = ""

        do {
            for try await line in Shell.stream(task: task, pipe: pipe) {
                completeOutput += line + "\n"

                if let match = line.firstMatch(of: percentRegex),
                   let percent = match.1.int {
                    await self.uploadProgress.updateProgress(of: url, to: Int64(percent))
                }
            }
        } catch {
            Self.logger.error("Upload output: \(completeOutput)")

            if Task.isCancelled {
                Self.logger.error("Upload to Notion cancelled by user.")
                throw DatabaseUploadError.userCancel
            } else {
                Self.logger.error("Failed to upload to Notion.")
                throw DatabaseUploadError.notionUploadError
            }
        }

        await self.uploadProgress.markProcessAsFinished(url: url)
    }
    
    private func uploadToAirtable(url: URL, airtableProfile: AirtableDBModel) async throws {
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
            ShellRawArgument(#"--attachment-columns-map "Palette Filename" "Palette Attachments""#),
            ShellFlag("--md"),
            ShellParameter(for: "--log", url: logPath),
            ShellFlag("--verbose"),
            ShellArgument(url: url)
        ])
        
        // Add rename key column if defined
        if !airtableProfile.renameKeyColumn.isEmpty {
            argumentList.append(ShellRawArgument("--rename-key-column \"Marker ID\" \(airtableProfile.renameKeyColumn.quoted)"))
        }
        
        let (task, pipe) = try Shell.createProcess(command: argumentList.getCommand(), pty: false)

        self.uploadProcesses.append(task)

        let percentRegex = /([0-9]+)%/
        
        var completeOutput = ""

        do {
            for try await line in Shell.stream(task: task, pipe: pipe) {
                completeOutput += line + "\n"

                if let match = line.firstMatch(of: percentRegex),
                   let percent = match.1.int {
                    await self.uploadProgress.updateProgress(of: url, to: Int64(percent))
                }
            }
        } catch {
            Self.logger.error("Upload output: \(completeOutput)")

            if Task.isCancelled {
                Self.logger.error("Upload to Airtable cancelled by user.")
                throw DatabaseUploadError.userCancel
            } else {
                Self.logger.error("Failed to upload to Airtable.")
                throw DatabaseUploadError.airtableUploadError
            }
        }

        // Success
        await self.uploadProgress.markProcessAsFinished(url: url)
    }
}
