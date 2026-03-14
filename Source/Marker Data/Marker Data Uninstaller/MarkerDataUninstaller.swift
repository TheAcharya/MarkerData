//
//  MarkerDataUninstaller.swift
//  Marker Data Uninstaller
//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import Foundation

enum MarkerDataUninstaller {
    /// Runs the uninstall process: terminate app, clear defaults domain, remove paths, write log.
    /// Returns a list of issue messages (empty on full success).
    nonisolated static func run() -> [String] {
        var issues: [String] = []
        var deletedPaths: [String] = []
        var undeletedPaths: [String] = []
        let home = FileManager.default.homeDirectoryForCurrentUser.path

        // Terminate Marker Data if running
        runCommand(
            executable: "/usr/bin/killall",
            arguments: ["Marker Data"],
            ignoreFailure: true,
            issues: &issues
        )

        // Purge preferences domain (domain name, not path)
        runCommand(
            executable: "/usr/bin/defaults",
            arguments: ["delete", "co.theacharya.MarkerData"],
            ignoreFailure: true,
            issues: &issues
        )

        // All paths to remove (must match what the main app and extension use)
        let folderPaths: [String] = [
            "/Applications/Marker Data.app",
            "\(home)/Movies/Marker Data Cache",
            "\(home)/Library/Saved Application State/co.theacharya.MarkerData.savedState",
            "\(home)/Library/WebKit/co.theacharya.MarkerData",
            "\(home)/Library/HTTPStorages/co.theacharya.MarkerData",
            "\(home)/Library/HTTPStorages/co.theacharya.MarkerData.binarycookies",
            "\(home)/Library/Containers/co.theacharya.MarkerData.WorkflowExtension",
            "\(home)/Library/Application Scripts/co.theacharya.MarkerData.WorkflowExtension",
            "\(home)/Library/Application Support/Marker Data",
            "\(home)/Library/Preferences/co.theacharya.MarkerData.plist"
        ]

        for path in folderPaths {
            if removeIfExists(path) {
                deletedPaths.append(path)
            } else {
                undeletedPaths.append(path)
            }
        }

        writeLog(deletedPaths: deletedPaths, undeletedPaths: undeletedPaths, home: home)

        return issues
    }

    @discardableResult
    nonisolated private static func removeIfExists(_ path: String) -> Bool {
        guard FileManager.default.fileExists(atPath: path) else {
            return true
        }
        do {
            try FileManager.default.trashItem(at: URL(fileURLWithPath: path), resultingItemURL: nil)
            return true
        } catch {
            // Don't add to issues (GUI); undeleted path is still written to the log file
            return false
        }
    }

    nonisolated private static func writeLog(deletedPaths: [String], undeletedPaths: [String], home: String) {
        let desktopPath = "\(home)/Desktop/Marker-Data_Uninstall_Log.txt"
        var logContent = "Deleted Files and Folders:\n"
        logContent += deletedPaths.isEmpty ? "None\n" : deletedPaths.joined(separator: "\n") + "\n"
        logContent += "\nUndeleted Files and Folders (Manual Deletion Required):\n"
        logContent += undeletedPaths.isEmpty ? "None\n" : undeletedPaths.joined(separator: "\n") + "\n"

        do {
            try logContent.write(toFile: desktopPath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write log: \(error.localizedDescription)")
        }
    }

    nonisolated private static func runCommand(
        executable: String,
        arguments: [String],
        ignoreFailure: Bool,
        issues: inout [String]
    ) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        process.standardOutput = Pipe()

        do {
            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 || ignoreFailure else {
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrText = String(decoding: stderrData, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let command = ([executable] + arguments).joined(separator: " ")
                let details = stderrText.isEmpty ? "exit code \(process.terminationStatus)" : stderrText
                issues.append("Command failed (\(command)): \(details)")
                return
            }
        } catch {
            guard !ignoreFailure else { return }
            let command = ([executable] + arguments).joined(separator: " ")
            issues.append("Unable to run command (\(command)): \(error.localizedDescription)")
        }
    }
}
