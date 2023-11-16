//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import CoreData

struct ConfigurationSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer
    @EnvironmentObject var configurationsModel: ConfigurationsModel
    
    // Sheets
    @State var showAddConfigurationSheet = false
    @State var showRenameConfigurationSheet = false
    
    @State var configurationToRename = ""
    
    /// Add or rename configuration text field value
    @State var configurationNameText = ""
    
    /// Whether the current configuration has unsaved changes
    @State var unsavedChanges = false
    
    // Alerts
    @State var showAddUnsavedChangesDialog = false
    @State var showSwitchUnsavedChangesDialog = false
    
    
    @State var showConfigurationAddAlert = false
    @State var configurationAddAlertMessage = ""
    @State var showConfigurationDelteAlert = false
    @State var showConfigurationLoadAlert = false
    @State var showConfigurationUpdateAlert = false
    @State var showConfigurationRenameAlert = false
    
    /// Currently highlighted configuration (not the active configuration)
    @State var selectedConfiguration = ""
    
    /// True if the selected configuration is the default
    var isDefaultConfigurationActive: Bool {
        configurationsModel.activeConfiguration == ConfigurationsModel.defaultConfigurationName
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            tableView
            
            mainButtons
            
            showConfigurationsFolder
            
            Spacer()
                .frame(height: 40)
        }
        .padding()
        .overlayHelpButton(url: settings.configurationSettingsURL)
        .navigationTitle("Configuration Settings")
        .onAppear {
            unsavedChanges = configurationsModel.checkForUnsavedChanges()
        }
        .alert("Couldn't create configuration", isPresented: $showConfigurationAddAlert) {
            Button("OK") { }
        } message: {
            Text(configurationAddAlertMessage)
        }
        .confirmationDialog("Unsaved Changes", isPresented: $showSwitchUnsavedChangesDialog) {
            // Save to current and switch (if not default configuration)
            if !isDefaultConfigurationActive {
                Button("Save changes to \(configurationsModel.activeConfiguration) and switch") {
                    // Save changes to current config
                    updateConfiguration(configurationsModel.activeConfiguration)
                    
                    // Load selected
                    loadConfiguration(selectedConfiguration)
                }
            }
            
            // Bring changes to new
            Button("Bring changes to \(selectedConfiguration)") {
                configurationsModel.activeConfiguration = selectedConfiguration
            }
            
            // Discard and switch
            Button("Discard changes and switch") {
                loadConfiguration(selectedConfiguration, ignoreChanges: true)
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog("Unsaved Changes", isPresented: $showAddUnsavedChangesDialog) {
            // Bring changes to new
            Button("Only save changes to new configuration") {
                showAddConfigurationSheet = true
            }
            
            // Save to current and create new
            Button("Save changes both \(configurationsModel.activeConfiguration) and to new configuration") {
                updateConfiguration(configurationsModel.activeConfiguration)
                showAddConfigurationSheet = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .alert("Failed to remove configuration", isPresented: $showConfigurationDelteAlert) { }
        .alert("Failed to load configuration", isPresented: $showConfigurationLoadAlert) { }
        .alert("Failed to update active configuration", isPresented: $showConfigurationUpdateAlert) { }
        .alert("Failed to rename configuration", isPresented: $showConfigurationRenameAlert) { }
    }
    
    // MARK: Views
    
    private var tableView: some View {
        List(self.configurationsModel.configurations, selection: $selectedConfiguration) { configuration in
            let isActive = configurationsModel.activeConfiguration == configuration.name
            
            let unsavedChangesText = if isActive && unsavedChanges {
                if isDefaultConfigurationActive {
                    "(unsaved changes, Default configuration cannot be modified)"
                } else {
                    "(unsaved changes)"
                }
            } else {
                ""
            }
            
            let stateIndicatorColor = if isActive {
                if unsavedChanges {
                    Color.orange
                } else {
                    Color.green
                }
            } else {
                Color.accentColor
            }
            
            Label(
                title: {
                    Text(configuration.name) +
                    Text(" \(unsavedChangesText)").fontWeight(.thin)
                },
                icon: {
                    Image(systemName: isActive ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(stateIndicatorColor)
                }
            )
            .tag(configuration.name)
            .contextMenu {
                contextMenuButtons(for: configuration.name)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /// Buttons to add and remove configurations
    private var mainButtons: some View {
        HStack {
            // Add configuration Button
            Button {
                withAnimation {
                    if unsavedChanges && configurationsModel.activeConfiguration != ConfigurationsModel.defaultConfigurationName {
                        showAddUnsavedChangesDialog = true
                    } else {
                        showAddConfigurationSheet = true
                    }
                }
            } label: {
                Image(systemName: "plus")
            }
            
            // Remove configuration button
            Button {
               removeConfiguration(selectedConfiguration)
            } label: {
                Image(systemName: "minus")
            }
            .disabled(selectedConfiguration.isEmpty || selectedConfiguration == ConfigurationsModel.defaultConfigurationName)
            
            Divider()
                .frame(maxHeight: 20)
            
            // Load configuration button
            Button() {
                loadConfiguration(selectedConfiguration)
            } label: {
                Label("Make Active", systemImage: "largecircle.fill.circle")
            }
            .disabled(selectedConfiguration.isEmpty || selectedConfiguration == configurationsModel.activeConfiguration)
            
            // Update active configuration button
            Button {
                updateConfiguration(configurationsModel.activeConfiguration)
            } label: {
                Label("Update Active Configuration", systemImage: "gearshape.arrow.triangle.2.circlepath")
            }
            .disabled(!unsavedChanges || isDefaultConfigurationActive)
        }
        .padding(.vertical)
        .sheet(isPresented: $showAddConfigurationSheet) {
            addOrRenameConfigurationModal()
                .frame(width: 500)
                .padding()
        }
        .sheet(isPresented: $showRenameConfigurationSheet) {
            addOrRenameConfigurationModal(rename: true)
                .frame(width: 500)
                .padding()
        }
    }
    
    /// Opens the configurations directory in Finder
    private var showConfigurationsFolder: some View {
        Button("Open Configuration Folder in Finder") {
            NSWorkspace.shared.open(
                URL(fileURLWithPath: URL.configurationsFolder.path().removingPercentEncoding ?? "")
            )
        }
        .buttonStyle(.link)
    }
    
    /// View used when right clicking a configuration
    private func contextMenuButtons(for configurationName: String) -> some View {
        VStack {
            // Load configuration
            Button {
                loadConfiguration(configurationName)
            } label: {
                Label("Make Active", systemImage: "largecircle.fill.circle")
            }
            .disabled(configurationName == configurationsModel.activeConfiguration)
            
            // If active configuration
            if configurationName == configurationsModel.activeConfiguration {
                // Discard changes button
                Button {
                    loadConfiguration(configurationsModel.activeConfiguration, ignoreChanges: true)
                } label: {
                    Label("Discard Changes", systemImage: "circle.slash")
                }
                .disabled(!unsavedChanges)
            }
            
            // If not default configuration
            if configurationName != ConfigurationsModel.defaultConfigurationName {
                if configurationName == configurationsModel.activeConfiguration {
                    // Update configuration
                    Button {
                        updateConfiguration(configurationName)
                    } label: {
                        Label("Update", systemImage: "gearshape.arrow.triangle.2.circlepath")
                    }
                    .disabled(!unsavedChanges)
                }
                
                // Rename configuration
                Button {
                    configurationToRename = configurationName
                    showRenameConfigurationSheet = true
                } label: {
                    Label("Rename", systemImage: "square.and.pencil")
                }
                
                Divider()
                
                // Remove configuration
                Button(role: .destructive) {
                    removeConfiguration(configurationName)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
        .labelStyle(.titleAndIcon)
    }
    
    private func addOrRenameConfigurationModal(rename: Bool = false) -> some View {
        func doAction() {
            if rename {
                renameConfiguration()
                showRenameConfigurationSheet = false
            } else {
                addConfiguration()
                showAddConfigurationSheet = false
            }
        }
        
        return VStack(alignment: .leading) {
            Text("\(rename ? "Rename" : "Add") Configuration")
                .font(.system(size: 18, weight: .bold))
            
            HStack {
                Text("Configuration Name:")
                
                TextField("Configuration Name", text: $configurationNameText)
                    .onChange(of: configurationNameText) { newName in
                        configurationNameText = String(newName.prefix(ConfigurationsModel.configurationNameCharacterLimit))
                    }
                    .onSubmit {
                        doAction()
                    }
            }
            
            HStack {
                Spacer()
                
                Button("Cancel", role: .cancel) {
                    showAddConfigurationSheet = false
                    showRenameConfigurationSheet = false
                }
                
                Button("Save") {
                    doAction()
                }
            }
        }
    }
    
    // MARK: Methods
    
    private func addConfiguration() {
        do {
            try configurationsModel.saveConfiguration(configurationName: configurationNameText)
        } catch ConfigurationSaveError.fileCreationError {
            configurationAddAlertMessage = "Couldn't create configuration file"
            showConfigurationAddAlert = true
        } catch ConfigurationSaveError.jsonSerializationError {
            configurationAddAlertMessage = "Couldn't load configuration contents"
            showConfigurationAddAlert = true
        } catch ConfigurationSaveError.nameAlreadyExists {
            configurationAddAlertMessage = "A configuration with the same name already exists"
            showConfigurationAddAlert = true
        } catch ConfigurationSaveError.nameTooLong {
            configurationAddAlertMessage = "Name too long"
            showConfigurationAddAlert = true
        } catch {
            configurationAddAlertMessage = "An uknown error occured"
            showConfigurationAddAlert = true
        }
    
        configurationNameText = ""
        showAddConfigurationSheet = false
        unsavedChanges = false
    }
    
    private func removeConfiguration(_ name: String) {
        do {
            try withAnimation {
                try configurationsModel.removeConfiguration(name: name)
            }
        } catch {
            showConfigurationDelteAlert = true
        }
        
        unsavedChanges = configurationsModel.checkForUnsavedChanges()
    }
    
    private func loadConfiguration(_ name: String, ignoreChanges: Bool = false) {
        if unsavedChanges && !ignoreChanges {
            showSwitchUnsavedChangesDialog = true
        } else {
            do {
                try withAnimation {
                    try configurationsModel.loadConfiguration(configurationName: name, settings: settings)
                    unsavedChanges = false
                }
            } catch {
                showConfigurationLoadAlert = true
            }
        }
    }
    
    private func updateConfiguration(_ name: String) {
        do {
            try withAnimation {
                try configurationsModel.saveConfiguration(configurationName: name, replace: true)
                unsavedChanges = false
            }
        } catch {
            showConfigurationUpdateAlert = true
        }
    }
    
    private func renameConfiguration() {
        do {
            try withAnimation {
                try configurationsModel.renameConfiguration(from: configurationToRename, to: configurationNameText)
            }
        } catch {
            showConfigurationRenameAlert = true
        }
    }
}

struct ConfigurationSettingsView_Previews: PreviewProvider {
    static let settings = SettingsContainer()
    
    static var previews: some View {
        ConfigurationSettingsView()
            .environmentObject(settings)
    }
}
