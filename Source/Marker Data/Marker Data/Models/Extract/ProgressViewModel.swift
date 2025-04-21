//
//  ProgressViewModel.swift
//  Marker Data
//
//  Created by Milán Várady on 26/12/2023.
//

import Foundation
import OSLog
import DockProgress

/// Holds the list of subprocesses and calculates the total progress
@MainActor
final class ProgressViewModel: ObservableObject {
    let progress: Progress = Progress(totalUnitCount: 100)
    
    /// Progressbar message
    @Published var message: String
    
    /// SF Symbol shown on the progress bar
    @Published var icon: String
    
    /// Task descripting showed on the progress bar
    var taskDescription: String
    var taskIcon: String

    var showDockProgress: Bool
    
    /// List of processes
    var processes: [ExportProcess] = []
    
    // Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ProgressViewModel")
    
    init(taskDescription: String, taskIcon: String, showDockProgress: Bool = true) {
        self.message = "\(taskDescription) - waiting..."
        self.icon = "clock"
        self.taskDescription = taskDescription
        self.taskIcon = taskIcon
        self.showDockProgress = showDockProgress
    }
    
    // Default: true
    private var shouldShowDockProgress: Bool {
        if !showDockProgress {
            return false
        } else {
            return UserDefaults.standard.boolOptional(forKey: "showDockProgress") ?? true
        }
    }
    
    /// Initializes new export processes
    func setProcesses(urls: [URL]) {
        self.processes = urls.map { ExportProcess(url: $0) }
        DockProgress.progressInstance = self.shouldShowDockProgress ? self.progress : nil
    }
    
    /// Adds a process
    func addProcess(url: URL) {
        self.processes.append(ExportProcess(url: url))
        
        // Only set on first addition
        if self.processes.count == 1 {
            DockProgress.progressInstance = self.shouldShowDockProgress ? self.progress : nil
        }
    }
    
    /// Update progress of a single process
    func updateProgress(of url: URL, to percentage: Int64) async {
        guard let process = self.processes.first(where: { $0.url == url }) else {
            Self.logger.error("Failed to update progress of: \(url)")
            return
        }

        process.progress.completedUnitCount = percentage

        await self.updateTotalProgress()
    }
    
    func markProcessAsFinished(url: URL) async {
        guard let process = self.processes.first(where: { $0.url == url }) else {
            Self.logger.error("Failed to mark \(url) as finished")
            return
        }

        process.progress.completedUnitCount = 100
        process.isFinished = true
        
        await self.updateTotalProgress()
        
        // Send notification
        await NotificationManager.sendNotification(
            taskFinished: false,
            title: "\(self.message)",
            body: "\(url.path(percentEncoded: false))"
        )
    }
    
    /// Calculate and update current progress
    private func updateTotalProgress() async {
        let processCount = self.processes.count
        
        // Calculate percent completed
        let total: Int64 = Int64(processCount * 100)
        let completed = self.processes
            .map({ $0.progress.completedUnitCount })
            .reduce(0, +)
        
        let percentageFraction: Float = Float(completed) / Float(total)
        let percentage: Int64 = Int64(percentageFraction * 100)
        
        // Calculate items done
        let processesDone = self.processes.filter({ $0.isFinished }).count
        let message = "\(taskDescription) (\(processesDone)/\(processCount))"
        
        // Update info
        if processesDone == processCount {
            // All complete
            self.progress.completedUnitCount = 100
            self.message = "\(taskDescription) done"
            self.icon = "checkmark"
        } else {
            // In progress
            self.progress.completedUnitCount = percentage
            self.message = message
            self.icon = taskIcon
        }
        
        // Publish progress
        self.objectWillChange.send()
    }
    
    /// Marks the progress as failed
    func markasFailed(progressMessage: String, alertMessage: String) {
        self.message = progressMessage
        self.icon = "xmark"
        
        // Alert
        self.showAlert = true
        self.alertMessage = alertMessage
    }
    
    func reset(taskDescription: String? = nil, taskIcon: String? = nil) {
        if let taskDescription { self.taskDescription = taskDescription }
        if let taskIcon { self.taskIcon = taskIcon }
        
        self.icon = "clock"
        self.processes.removeAll()
        self.progress.totalUnitCount = 100
        self.progress.completedUnitCount = 0
    }
}
