//
//  ShellArgumentList.swift
//  Marker Data
//
//  Created by Milán Várady on 11/02/2024.
//

import Foundation

struct ShellArgumentList {
    var executablePath: URL
    var parameters: [any ShellOption]
    
    init(executablePath: URL, parameters: [any ShellOption]) {
        self.executablePath = executablePath
        self.parameters = parameters
    }
    
    init(executablePath: URL) {
        self.executablePath = executablePath
        self.parameters = []
    }
    
    mutating func append(_ parameter: any ShellOption) {
        self.parameters.append(parameter)
    }
    
    func getCommand() -> String {
        let executablePathString = executablePath.path(percentEncoded: false).quoted
        
        let commands: [String] = self.parameters.map {
            $0.toString()
        }
        let commandsString = commands.joined(separator: " ")
        
        return "\(executablePathString) \(commandsString)"
    }
}

protocol ShellOption {
    func toString() -> String
}

struct ShellArgument: ShellOption {
    let argument: String
    
    init(_ argument: String) {
        self.argument = argument
    }
    
    init(url: URL) {
        self.argument = url.path(percentEncoded: false).quoted
    }
    
    func toString() -> String {
        return if !self.argument.hasPrefix(#"""#) && !self.argument.hasSuffix(#"""#) {
            self.argument.quoted
        } else {
            self.argument
        }
    }
}

struct ShellFlag: ShellOption {
    let flag: String
    
    init(_ flag: String) {
        self.flag = flag
    }
    
    func toString() -> String {
        return self.flag
    }
}

struct ShellParameter: ShellOption {
    let option: String
    let value: String
    
    init(for option: String, value: String) {
        self.option = option
        self.value = value
    }
    
    init(for option: String, url: URL) {
        self.option = option
        self.value = url.path(percentEncoded: false)
    }
    
    func toString() -> String {
        // Add quotes to value
        let valueQuoted = if !self.value.hasPrefix(#"""#) && !self.value.hasSuffix(#"""#) {
            self.value.quoted
        } else {
            self.value
        }
        
        return "\(option) \(valueQuoted)"
    }
}

struct ShellRawArgument: ShellOption {
    let argument: String
    
    init(_ argument: String) {
        self.argument = argument
    }
    
    func toString() -> String {
        return argument
    }
}
