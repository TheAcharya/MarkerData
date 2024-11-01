//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import SwiftUI

struct ConfigurationSettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

    @StateObject var confModel = ConfigurationsViewModel()

    // Sheets
    @State var showAddConfigurationSheet = false
    @State var showRenameConfigurationSheet = false
    @State var configurationToRename = ""
    
    /// Add or rename configuration text field value
    @State var configurationNameText = ""

    @State var showAddUnsavedChangesDialog = false
    @State var showSwitchUnsavedChangesDialog = false

    @State var showRemoveConfigurationConfirm = false
    
    /// Currently highlighted configuration (not the active configuration)
    @State var selectedStoreName: String = ""

    var selectedStore: SettingsStore? {
        return settings.findByName(selectedStoreName)
    }

    var body: some View {
        VStack(alignment: .leading) {
            tableView
            
            mainButtons
            
            showConfigurationsFolder
        }
        .padding()
        .overlayHelpButton(url: Links.configurationSettingsURL)
        .navigationTitle("Configuration Settings")
        .onAppear {
            // Set view models settings
            confModel.settings = self.settings
        }
        // Shown when switching conf but there are unsaved changes
        .confirmationDialog("Unsaved Changes", isPresented: $showSwitchUnsavedChangesDialog) {
            // Save to current and switch (if not default configuration)
            if !settings.isDefaultActive {
                Button("Save changes to \(settings.store.name) and switch") {
                    // Save changes to current config
                    confModel.updateCurrent()

                    // Load selected
                    confModel.makeActive(selectedStore)
                }
            }
            
            // Discard and switch
            Button("Discard changes and switch") {
                confModel.makeActive(selectedStore)
            }
            
            Button("Cancel", role: .cancel) { }
        }
        // Shown when adding new conf but there are unsaved changes
        .confirmationDialog("Unsaved Changes", isPresented: $showAddUnsavedChangesDialog) {
            // Bring changes to new
            Button("Only save changes to new configuration") {
                showAddConfigurationSheet = true
            }
            
            // Save to current and create new
            Button("Save changes both \(settings.store.name) and to new configuration") {
                confModel.updateCurrent()
                showAddConfigurationSheet = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        // Remove configuration confirmation dialog
        .confirmationDialog("Delete configuration \(selectedStoreName.quoted)? This action cannot be undone.", isPresented: $showRemoveConfigurationConfirm) {
            Button("Delete", role: .destructive) {
                confModel.remove(name: selectedStoreName)
                self.selectedStoreName = ""
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(confModel.alertTitle, isPresented: $confModel.showAlert) {

        } message: {
            Text(confModel.alertMessage)
        }
    }
    
    // MARK: Views
    
    private var tableView: some View {
        List(self.settings.configurations, selection: $selectedStoreName) { configuration in
            let isActive = configuration.name == settings.store.name

            let unsavedChangesText = if isActive && settings.unsavedChanges {
                if settings.isDefaultActive {
                    "(unsaved changes, Default configuration cannot be modified)"
                } else {
                    "(unsaved changes)"
                }
            } else {
                ""
            }
            
            let stateIndicatorColor = if isActive {
                if settings.unsavedChanges {
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
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu(forSelectionType: String.self) { storeNames in
            if let storeName = storeNames.first,
               let store = settings.findByName(storeName) {
                contextMenuButtons(for: store)
            }
        }
    }
    
    /// Buttons to add and remove configurations
    private var mainButtons: some View {
        HStack {
            // Add configuration Button
            Button {
                withAnimation {
                    if settings.unsavedChanges && !settings.isDefaultActive {
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
               showRemoveConfigurationConfirm = true
            } label: {
                Image(systemName: "minus")
            }
            .disabled(selectedStore == nil || selectedStore?.isDefault() ?? false)

            Divider()
                .frame(maxHeight: 20)
            
            // Load configuration button
            Button {
                if settings.unsavedChanges && !settings.isDefaultActive {
                    showSwitchUnsavedChangesDialog = true
                } else {
                    confModel.makeActive(selectedStore)
                }
            } label: {
                Label("Make Active", systemImage: "largecircle.fill.circle")
            }
            .disabled(selectedStore == nil || selectedStore == settings.store)

            Button {
                confModel.duplicateConfiguration(store: selectedStore)
            } label: {
                Label("Duplicate", systemImage: "square.filled.on.square")
            }
            .disabled(selectedStore.isNone)
            .keyboardShortcut("D", modifiers: .command)

            // Update active configuration button
            Button {
                confModel.updateCurrent()
            } label: {
                Label("Update Active Configuration", systemImage: "gearshape.arrow.triangle.2.circlepath")
            }
            .disabled(!settings.unsavedChanges || settings.isDefaultActive)
        }
        .padding(.bottom)
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
        Button {
            NSWorkspace.shared.open(URL.configurationsFolder)
        } label: {
            Label("Open Configuration Folder in Finder", systemImage: "folder")
        }
        .buttonStyle(.link)
    }
}

#Preview {
    let settings = SettingsContainer()

    return ConfigurationSettingsView()
        .environmentObject(settings)
}
