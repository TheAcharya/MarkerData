//
//  ProgressViewModel.swift
//  Marker Data
//
//  Created by Milán Várady on 26/12/2023.
//

import Foundation
import os

/// Holds the list of subprocesses and calculates the total progress
class ProgressViewModel: ObservableObject {
    let progress: Progress = Progress(totalUnitCount: 100)
    
    /// Progressbar message
    @Published var message: String
    
    /// SF Symbol shown on the progress bar
    @Published var icon: String
    
    /// Task descripting showed on the progress bar
    let taskDescription: String
    
    /// List of processes
    var processes: [ExportProcess] = []
    
    // Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    static let logger = Logger(subsystem: "ProgressViewModel", category: "")
    
    init(taskDescription: String) {
        self.message = "\(taskDescription) - waiting..."
        self.icon = "clock"
        self.taskDescription = taskDescription
    }
    
    /// Initializes new export processes
    public func setProcesses(urls: [URL]) {
        self.processes = urls.map { ExportProcess(url: $0) }
    }
    
    /// Adds a process
    public func addProcess(url: URL) {
        self.processes.append(ExportProcess(url: url))
    }
    
    /// Update progress of a single process
    @MainActor
    public func updateProgress(of url: URL, to percentage: Int64) async {
        guard let process = self.processes.first(where: { $0.url == url }) else {
            Self.logger.error("Failed to update progress of: \(url)")
            return
        }

        process.progress.completedUnitCount = percentage

        await self.updateTotalProgress()
    }
    
    public func markProcessAsFinished(url: URL) async {
        guard let process = self.processes.first(where: { $0.url == url }) else {
            Self.logger.error("Failed to mark \(url) as finished")
            return
        }
        
        process.isFinished = true
        
        await self.updateTotalProgress()
    }
    
    /// Calculate and update current progress
    @MainActor
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
            self.icon = "gearshape.2"
        }
        
        // Publish progress
        await MainActor.run {
            self.objectWillChange.send()
        }
    }
    
    /// Marks the progress as failed
    public func markasFailed(progressMessage: String, alertMessage: String) {
        self.message = progressMessage
        self.icon = "xmark"
        
        // Alert
        self.showAlert = true
        self.alertMessage = alertMessage
    }
    
    public func reset() {
        self.message = "\(taskDescription) - waiting..."
        self.icon = "clock"
        self.processes.removeAll()
        self.progress.completedUnitCount = 0
    }
}