//
//  SettingsView.swift
//  Marker Data
//
//  Created by Mark Howard on 14/01/2023.
//

import SwiftUI
import FontPicker

struct SettingsView: View {
    //Default Selected Export Format
    @AppStorage("selectedExportFormat") var selectedExportFormat = 1
    //Default Selected Exclude Roles
    @AppStorage("selectedExcludeRoles") var selectedExcludeRoles = 1
    //Are Subframes Enabled
    @AppStorage("enabledSubframes") var enabledSubframes = false
    //Default Selected ID Naming Mode
    @AppStorage("selectedIDNamingMode") var selectedIDNamingMode = 1
    //Default Selected Image Mode
    @AppStorage("selectedImageMode") var selectedImageMode = 1
    //Default Selected JPG Image Quality
    @AppStorage("selectedImageQuality") var selectedImageQuality = 100.0
    //Default Image Width
    @AppStorage("imageWidth") var imageWidth = "1920"
    //Default Image Height
    @AppStorage("imageHeight") var imageHeight = "1080"
    //Default Image Scale Size
    @AppStorage("selectedImageSize") var selectedImageSize = 100.0
    //Default Set GIF FPS
    @AppStorage("selectedGIFFPS") var selectedGIFFPS = "10"
    //Default Set GIF Length Span
    @AppStorage("selectedGIFLength") var selectedGIFLength = "2"
    //Default Selected Font
    @State var selectedFont: NSFont = NSFont.systemFont(ofSize: 24)
    //Default Horizontal Alignment
    @AppStorage("selectedHorizontalAlignment") var selectedHorizonalAlignment = 1
    //Default Vertical Alignment
    @AppStorage("selectedVerticallignment") var selectedVerticalAlignment = 1
    //Default Copyright Text
    @AppStorage("copyrightText") var copyrightText = ""
    //Is Notion Enabled
    @AppStorage("isNotionEnabled") var isNotionEnabled = false
    //Is Notion Merge With Existing Database On
    @AppStorage("notionMergeWithExistingDatabase") var notionMergeWithExistingDatabase = false
    //Regestered Notion Token
    @AppStorage("notionToken") var notionToken = ""
    //Regestered Notion Database URL
    @AppStorage("notionDatabaseURL") var notionDatabaseURL = ""
    //Main Settings View Controller
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView {
                List {
                    //Link To General Settings
                    NavigationLink(destination: general) {
                        Label("General", systemImage: "gearshape")
                    }
                    //Link To Image Settings
                    NavigationLink(destination: image) {
                        Label("Image", systemImage: "photo")
                    }
                    //Link To Label Settings
                    NavigationLink(destination: label) {
                        Label("Label", systemImage: "tag")
                    }
                    //Link To Configuration Settings
                    NavigationLink(destination: config) {
                        Label("Configuration", systemImage: "slider.vertical.3")
                    }
                    Divider()
                    //Minimisable Database Settings Section
                    Section(header: Text("Databases")) {
                        //Link To Notion Settings
                        NavigationLink(destination: notion) {
                            Label("Notion", systemImage: "lightbulb")
                        }
                    }
                }
                //Define List Style As Sidebar
                .listStyle(.sidebar)
            } detail: {
                //Show App Icon And App Title When No Setting Section Is Selected
                VStack {
                    Image("AppsIcon")
                        .resizable()
                        .cornerRadius(25)
                        .frame(width: 150, height: 150)
                    Text("Marker Data")
                        .bold()
                        .font(.title)
                }
            }
            //Set Settings Window Static Width And Height
            .frame(width: 700, height: 400)
            //Hide Toolbar
            .toolbar(.hidden)
        } else {
            // Fallback On Earlier Versions
            NavigationView {
                List {
                    //Link To General Settings
                    NavigationLink(destination: general) {
                        Label("General", systemImage: "gearshape")
                    }
                    //Link To Image Settings
                    NavigationLink(destination: image) {
                        Label("Image", systemImage: "photo")
                    }
                    //Link To Label Settings
                    NavigationLink(destination: label) {
                        Label("Label", systemImage: "tag")
                    }
                    //Link To Configuration Settings
                    NavigationLink(destination: config) {
                        Label("Configuration", systemImage: "slider.vertical.3")
                    }
                    Divider()
                    //Minimisable Database Settings Section
                    Section(header: Text("Databases")) {
                        //Link To Notion Settings
                        NavigationLink(destination: notion) {
                            Label("Notion", systemImage: "lightbulb")
                        }
                    }
                }
                //Define List Style As Sidebar
                .listStyle(SidebarListStyle())
                //Show App Icon And App Title When No Setting Section Is Selected
                VStack {
                    Image("AppsIcon")
                        .resizable()
                        .cornerRadius(25)
                        .frame(width: 150, height: 150)
                    Text("Marker Data")
                        .bold()
                        .font(.title)
                }
            }
            //Set Settings Window Static Width And Height
            .frame(width: 700, height: 400)
            //Hide Toolbar
            
        }
    }
    //General Settings Section
    var general: some View {
      Form {
        HStack {
            VStack(alignment: .leading) {
                //Button To Set File Export Destination
                Button(action: {}) {
                    Text("Set Export Destination")
                }
                //Selected Export Path
                Text("PATH HERE")
                    .bold()
                //Button To Show Export Destination In Finder
                Button(action: {}) {
                    Text("Reveal Destination In Finder")
                }
                //Picker To Change Default Export Format
                Picker("Export Format", selection: $selectedExportFormat) {
                    Text("Notion")
                        .tag(1)
                    Text("Airtable")
                        .tag(2)
                }
                //Picker To Change Default Exclude Roles
                Picker("Exclude Roles", selection: $selectedExcludeRoles) {
                    Text("None")
                        .tag(1)
                    Text("Video")
                        .tag(2)
                    Text("Audio")
                        .tag(3)
                }
                //Toggle To Enable Subframes
                Toggle("Enable Subframes", isOn: $enabledSubframes)
                //Make Toggle A Checkbox
                    .toggleStyle(.checkbox)
            }
            Spacer()
        }
        .padding(.horizontal)
      }
    //Set Navigation Bar Title To General
      .navigationTitle("General")
    }
    //Image Settings Section
    var image: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Picker To Change Selected ID Naming Mode
                    Picker("ID Naming Mode", selection: $selectedIDNamingMode) {
                        Text("Timecode")
                            .tag(1)
                        Text("Name")
                            .tag(2)
                        Text("Notes")
                            .tag(3)
                    }
                    //Picker To Change Selected Image Mode
                    Picker("Image Mode", selection: $selectedImageMode) {
                        Text("PNG")
                            .tag(1)
                        Text("JPG")
                            .tag(2)
                        Text("GIF")
                            .tag(3)
                    }
                    //Slider To Set JPG Image Quality
                    Slider(value: $selectedImageQuality, in: 1...100, step: 1) {
                            Text("Image Quality")
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("100")
                        } onEditingChanged: { editing in
                            print("Changed JPG Quality To \(selectedImageQuality)")
                        }
                    //Display Text To Show The Current Image Quality
                    Text("Current Image Quality - \(selectedImageQuality)".dropLast(2))
                        .bold()
                    //Text Fields To Set Image Width And Height
                    HStack {
                        TextField("Image Width", text: $imageWidth)
                            .padding(.trailing)
                        TextField("Image Height", text: $imageHeight)
                    }
                    //Slider To Set Image Size In Percentages
                    Slider(value: $selectedImageQuality, in: 1...100, step: 1) {
                            Text("Image Size (%)")
                        } minimumValueLabel: {
                            Text("1")
                        } maximumValueLabel: {
                            Text("100")
                        } onEditingChanged: { editing in
                            print("Changed Image Size To \(selectedImageQuality)")
                        }
                    //Display Text To Show Current Image Size In %
                    Text("Current Image Size - \(selectedImageSize)".dropLast(2))
                        .bold()
                    //Text Field To Set GIF FPS Rate
                    TextField("GIF FPS", text: $selectedGIFFPS)
                    //Text Field To Set GIF Time Span
                    TextField("GIF Span (Sec)", text: $selectedGIFLength)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        //Set Navgation Bar Title To Image
        .navigationTitle("Image")
    }
    //Label Settings Section
    var label: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Button To Open Font Picker Component
                    FontPicker("Font", selection: $selectedFont)
                    //Picker To Change Horizonal Alignment
                    Picker("Horizonal Alignment", selection: $selectedHorizonalAlignment) {
                        Text("Left")
                            .tag(1)
                        Text("Center")
                            .tag(2)
                        Text("Right")
                            .tag(3)
                    }
                    //Picker To Change Vertical Alignment
                    Picker("Vertical Alignment", selection: $selectedVerticalAlignment) {
                        Text("Top")
                            .tag(1)
                        Text("Center")
                            .tag(2)
                        Text("Bottom")
                            .tag(3)
                    }
                    //Label Tag Chips
                    Text("INSERT LABELS HERE")
                    //Text Field To Enter Copyright
                    TextField("Copyright", text: $copyrightText)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        //Set Navigation Bar Title To Label
        .navigationTitle("Label")
    }
    //Configuration Settings Section
    var config: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Button To Save Marker Settings
                    Button(action: {}) {
                        Text("Save Marker Settings")
                    }
                    //Button To Load Marker Settings
                    Button(action: {}) {
                        Text("Load Marker Settings")
                    }
                    //Button To Load Default Marker Settings
                    Button(action: {}) {
                        Text("Load Defaults")
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        //Set Navigation Bar Title To Configuration
        .navigationTitle("Configuration")
    }
    //Notion Settings Section
    var notion: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Toggle To Enable Notion
                    Toggle("Enable Notion", isOn: $isNotionEnabled)
                    //Make Toggle A Checkbox
                        .toggleStyle(.checkbox)
                    //Toggle To Merge With Existing Notion Database
                    Toggle("Merge With Existing Database", isOn: $notionMergeWithExistingDatabase)
                    //Make Toggle A Checkbox
                        .toggleStyle(.checkbox)
                    //Text Field To Enter Notion Token And Find Token Button
                    HStack {
                        TextField("Notion Token (Required)", text: $notionToken)
                            .padding(.trailing)
                        Button(action: {}) {
                            Text("Find Token")
                        }
                    }
                    //Text Field To Enter Database URL And Find Database Button
                    HStack {
                        TextField("Notion Database URL (Optional)", text: $notionDatabaseURL)
                            .padding(.trailing)
                        Button(action: {}) {
                            Text("Find Database")
                        }
                    }
                    //Button To Open Notion Template
                    Button(action: {}) {
                        Text("Open Notion Template")
                    }
                    //Button To Save Notion Settings
                    Button(action: {}) {
                        Text("Save Notion Settings")
                    }
                    //Button To Load Notion Settings
                    Button(action: {}) {
                        Text("Load Notion Settings")
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        //Set Navigation Bar Title To Notion
        .navigationTitle("Notion")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
