//
//  ShellOutputStream.swift
//  Applite
//
//  Created by Milán Várady on 2023. 01. 14..
//

import Foundation
import Combine

/// Streams the output of a shell command in real time
class ShellOutputStream {
    public let outputPublisher = PassthroughSubject<String, Never>()
    public var task: Process? = Process()
    
    private var output: String = ""
    private var fileHandle: FileHandle?
    
    /// Runs shell command
    ///
    /// - Parameters:
    ///  - command: Shell command to run
    ///  - environmentVariables: (optional) Environment varables to include in the command
    ///
    /// - Returns: A ``ShellResult`` containing the output and exit status of command
    func run(_ command: String) async -> ShellResult {
        if self.task == nil {
            self.task = Process()
        }
        
        self.task?.launchPath = "/bin/zsh"
        self.task?.arguments = ["-l", "-c", "script -q /dev/null \(command)"]
        
        let pipe = Pipe()
        self.task?.standardOutput = pipe
        self.fileHandle = pipe.fileHandleForReading
        
        // Read in output changes
        self.fileHandle?.readabilityHandler = { [weak self] handle in
            guard let self = self else { return }
            let data = handle.availableData
            
            if data.count > 0 {
                let text = String(data: data, encoding: .utf8) ?? ""
                let cleanOutput = text.replacingOccurrences(of: "\\\u{001B}\\[[0-9;]*[a-zA-Z]", with: "", options: .regularExpression)
                
                // Send new changes
                Task { @MainActor in
                    self.outputPublisher.send(cleanOutput)
                }
                
                self.output += cleanOutput
            } else if !(self.task?.isRunning ?? false) {
                self.fileHandle?.readabilityHandler = nil
            }
        }
        
        self.task?.launch()
        
        self.task?.waitUntilExit()
        
        return ShellResult(output: self.output, didFail: self.task?.terminationStatus ?? -1 != 0)
    }
}
