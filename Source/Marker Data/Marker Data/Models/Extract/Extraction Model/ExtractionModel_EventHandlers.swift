//
//  ExtractionModel_EventHandlers.swift
//  Marker Data
//
//  Created by Milán Várady on 04/02/2024.
//

import Foundation

extension ExtractionModel {
    func setupEventHandlers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenDocument(notification:)),
            name: .openFile,
            object: nil)
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkflowExtensionEvent),
            name: .workflowExtensionFileReceived,
            object: nil)
    }
    
    /// Handles the Open Document event, called when file is dragged to dock icon or FCP Share Destination exports
    @MainActor 
    @objc func handleOpenDocument(notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else {
            Self.logger.error("handleOpenDocument: Couldn't find URL info")
            return
        }
        
        Self.logger.notice("handleOpenDocument: Received url: \(url)")
        
        // Check if URL conforms to supported file types
        if !url.conformsToType(Self.supportedContentTypes) {
            Self.logger.error("handleOpenDocument: File type not supported (\(url.pathExtension))")
            return
        }
        
        // Show UI
        self.showProgressUI = true
        
        // Check if destination folder exists
        if let exportFolder = self.settings.store.exportFolderURL,
           exportFolder.fileExists {
            // Extract
            Task {
                await self.performExtraction([url])
            }
        } else {
            // Default to opening external file recieved popup
            self.externalFileRecieved = true
            self.externalFileURL = url
        }
        
        // Send notification
        NotificationManager.sendNotification(
            taskFinished: false,
            title: "Recieved External File",
            body: "\(url.path(percentEncoded: false))"
        )
    }
    
    /// Handles Workflow Extension notification, and starts the extraction
    @MainActor 
    @objc func handleWorkflowExtensionEvent() {
        Self.logger.notice("handleWorkflowExtensionEvent: Recieved notification")
        
        let url = URL.workflowExtensionExportFCPXML
        
        // Check if URL conforms to supported file types
        if !url.fileExists {
            Self.logger.error("handleWorkflowExtensionEvent: \(url.path(percentEncoded: false)) doesn't exist")
            return
        }
        
        // Show UI
        self.showProgressUI = true
        
        // Check if destination folder exists
        if let exportFolder = self.settings.store.exportFolderURL,
           exportFolder.fileExists {
            // Extract
            Task {
                await self.performExtraction([url])
            }
        } else {
            // Default to opening external file recieved popup
            self.externalFileRecieved = true
            self.externalFileURL = url
        }
        
        // Send notification
        NotificationManager.sendNotification(
            taskFinished: false,
            title: "Recieved External File",
            body: "\(url.path(percentEncoded: false))"
        )
    }
    
    public func processExternalFile() {
        defer {
            self.externalFileRecieved = false
            self.externalFileURL = nil
        }
        
        guard let url = self.externalFileURL else {
            return
        }
        
        Task {
            await self.performExtraction([url])
        }
    }
    
    @MainActor
    public func cancelExternalFile() {
        self.showProgressUI = false
        self.externalFileRecieved = false
        self.externalFileURL = nil
    }
}
