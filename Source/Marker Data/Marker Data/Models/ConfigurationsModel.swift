//
//  ConfigurationsModel.swift
//  Marker Data
//
//  Created by Milán Várady on 10/10/2023.
//

import Foundation
import SwiftUI
import os

/// Holds and modifies configurations
///
/// Stores the user defined configurations (saved export settings) and provides methods to modify them.
/// The exported settings are each stored in a json file loacated at `~/Application Support/Marker Data/Configurations`.
/// The class has a `@Published` property called `configurations` that holds all configuration names,
/// wich is the same as the filename without the .json extension.
class ConfigurationsModel: ObservableObject {
    /// Holds the current configurations
    @Published var configurations: [ConfigurationItem] = []
    
    /// Currently loaded configuration
    @AppStorage("selectedConfiguration") var activeConfiguration = "Default"
    
    static let logger = Logger()
    
    static let defaultConfigurationName = "Default"
    static let defaultConfigurationFileName = "DefaultConfiguration"
    static let configurationNameCharacterLimit = 50
    
    init() {
        // Create configurations directory in case it doesn't exist yet
        createConfigurationsDirectory()
        
        // Add Default config to list
        self.configurations.append(ConfigurationItem(name: Self.defaultConfigurationName))
        
        let filemanager = FileManager.default
        
        do {
            // Scan the configuration directory for configuration files
            let items = try filemanager.contentsOfDirectory(atPath: URL.configurationsFolder.path().removingPercentEncoding!)
            
            for item in items {
                if item.hasSuffix(".json") {
                    self.configurations.append(ConfigurationItem(name: String(item.dropLast(5))))
                }
            }
        } catch {
            Self.logger.error("Failed to load configurations")
            // TODO: handle load error
            //            throw ConfigurationInitializationError.failedToReadDirectory
        }
    }
    
    /// Saves a new configuration under the given name
    ///
    /// - Parameters:
    ///     - configurationName: Name of the configuration
    func saveConfiguration(configurationName: String, replace: Bool = false) throws {
        // Limit name length
        if configurationName.count > Self.configurationNameCharacterLimit {
            throw ConfigurationSaveError.nameTooLong
        }
        
        // Check if configuration with the same name exists
        if !replace && self.configurations.contains(where: { $0.name == configurationName }) {
            throw ConfigurationSaveError.nameAlreadyExists
        }
        
        // Get the current UserDefaults settings in a dictionary format
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation().filter {
            Self.keysToSave.contains($0.key)
        }
        
        // Turn into json
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            throw ConfigurationSaveError.jsonSerializationError
        }
        
        let url = URL.configurationsFolder.appendingPathComponent("\(configurationName).json", conformingTo: .json)
        
        // Remove if replacing
        if replace {
            try self.removeConfiguration(name: configurationName)
        }
        
        // Save file
        do {
            try data.write(to: url)
        } catch {
            throw ConfigurationSaveError.fileCreationError
        }
        
        // Add configuration name to configurations list
        self.configurations.append(ConfigurationItem(name: configurationName))
        
        // Set active configuration to new configuration
        self.activeConfiguration = configurationName
    }
    
    /// Loads a configuration from the configurations folder
    ///
    /// - Parameters:
    ///     - configurationName: Name of the configuration
    @MainActor
    func loadConfiguration(configurationName: String, settings: SettingsContainer) throws {
        // Check if configuration name is empty
        if configurationName.isEmpty {
            throw ConfigurationLoadError.emptyConfigurationName
        }
        
        // Load export settings into dictionary format
        do {
            let dictionary = if configurationName == Self.defaultConfigurationName {
                try loadDefaultsDicitionary()
            } else {
                try getConfigurationDictionary(configurationName: configurationName)
            }
            
            UserDefaults.standard.setValuesForKeys(dictionary)
        } catch {
            Self.logger.error("Failed to load configuration file. Message: \(error.localizedDescription)")
            throw ConfigurationLoadError.fileDoesntExists
        }
        
        UserDefaults.standard.synchronize()
        
        Task {
            await settings.reloadStore()
        }
        
        // Set active configuration
        self.activeConfiguration = configurationName
    }
    
    /// Renames configuration
    ///
    /// - Parameters:
    ///     - from: Configuration to rename
    ///     - to:  New name
    func renameConfiguration(from oldName: String, to newName: String) throws {
        let filemanager = FileManager.default
        
        let fromPath = URL.configurationsFolder.appendingPathComponent("\(oldName).json", conformingTo: .json)
        let toPath = URL.configurationsFolder.appendingPathComponent("\(newName).json", conformingTo: .json)
        
        try filemanager.moveItem(at: fromPath, to: toPath)
        
        // Change active configuration if needed
        if self.activeConfiguration == oldName {
            self.activeConfiguration = newName
        }
        
        // Remove old name from configurations list
        if let index = self.configurations.firstIndex(where: { $0.name == oldName }) {
            self.configurations.remove(at: index)
        }
        
        // Add new to name to configurations list
        self.configurations.append(ConfigurationItem(name: newName))
    }
    
    /// Removes a configuration
    ///
    /// - Parameters:
    ///     - name: Name of the configuration to remove
    func removeConfiguration(name: String) throws {
        let filemanager = FileManager()
        
        try filemanager.removeItem(at: URL.configurationsFolder.appendingPathComponent("\(name).json", conformingTo: .json))
        
        // Remove from configurations list
        if let index = self.configurations.firstIndex(where: { $0.name == name }) {
            self.configurations.remove(at: index)
        }
        
        // Change active configuration if the removed one was the active configuration
        if self.activeConfiguration == name && !self.configurations.isEmpty {
            self.activeConfiguration = self.configurations.first!.name
        }
    }
    
    /// Loads a configuration from the configurations folder into a ``Dictionary`` format
    ///
    /// - Parameters:
    ///     - configurationName: Name of the configuration
    private func getConfigurationDictionary(configurationName: String) throws -> Dictionary<String, Any> {
        let url = URL.configurationsFolder.appendingPathComponent("\(configurationName).json", conformingTo: .json)
        
        guard let data = try? Data(contentsOf: url) else {
            throw ConfigurationLoadError.fileDoesntExists
        }
        
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ConfigurationLoadError.jsonParseError
        }
        
        return dictionary
    }
    
    /// Loads default configuration from resources
    func loadDefaultsDicitionary() throws -> Dictionary<String, Any> {
//        guard
//            let url = Bundle.main.url(forResource: Self.defaultConfigurationFileName, withExtension: "json"),
//            let data = try? Data(contentsOf: url),
//            let configDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//        else {
//            throw ConfigurationLoadError.fileDoesntExists
//        }
        
        do {
            if let url = Bundle.main.url(forResource: Self.defaultConfigurationFileName, withExtension: "json") {
                let data = try Data(contentsOf: url)
                let configDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                return configDict
            }
        } catch {
            Self.logger.error("Failed to load defaults dict. Message: \(error.localizedDescription)")
            throw ConfigurationLoadError.fileDoesntExists
        }
        
        throw ConfigurationLoadError.fileDoesntExists
    }
    
    /// Returns true if there are unsaved changes to active configuration
    func checkForUnsavedChanges() -> Bool {
        do {
            let saved = if self.activeConfiguration == Self.defaultConfigurationName {
                try loadDefaultsDicitionary()
            } else {
                try getConfigurationDictionary(configurationName: self.activeConfiguration)
            }
            
            let current = UserDefaults.standard.dictionaryRepresentation().filter {
                Self.keysToSave.contains($0.key)
            }
            
            return !NSDictionary(dictionary: current).isEqual(to: saved)
        } catch {
            return false
        }
    }
    
    /// Creates configurations directory if it doesn't exist already
    private func createConfigurationsDirectory() {
        let fileManager = FileManager.default
        
        let pathString = URL.configurationsFolder.path().removingPercentEncoding ?? ""
        var isDir : ObjCBool = false
        
        if !fileManager.fileExists(atPath: pathString, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: URL.configurationsFolder, withIntermediateDirectories: true)
            } catch {
                Self.logger.error("Failed to create Configurations directory")
            }
        }
    }
    
    /// The set of keys saved from the `UserDefaults` when creating a Configuration
    private static let keysToSave = ["exportFolderURL", "selectedFolderFormat", "selectedExportFormat", "selectedExcludeRoles", "selectedImageMode", "isUploadEnabled", "enabledSubframes", "enabledClipBoundaries", "enabledNoMedia", "selectedIDNamingMode", "selectedImageQuality", "imageWidth", "imageWidthEnabled", "imageHeight", "imageHeightEnabled", "selectedImageSize", "selectedGIFFPS", "selectedGIFLength", "selectedFontNameType", "selectedFontStyleType", "selectedFontSize", "selectedStrokeSize", "isStrokeSizeAuto", "selectedFontColor", "selectedFontColorOpacity", "selectedStrokeColor", "selectedHorizontalAlignment", "selectedVerticallignment", "selectedOverlays", "copyrightText", "hideLabelNames"]
}

struct ConfigurationItem: Identifiable, Hashable {
    let name: String
    
    var id: String {
        name
    }
}
