//
//  SettingsView.swift
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
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
    //Init Chips View Model
    @StateObject var viewModel = ChipsViewModel()
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
                    //Link To Database Settings
                    NavigationLink(destination: databases) {
                        Label("Databases", systemImage: "list.bullet")
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
                    //Link To Database Settings
                    NavigationLink(destination: databases) {
                        Label("Databases", systemImage: "list.bullet")
                    }
                }
                //Define List Style As Sidebar
                .listStyle(.sidebar)
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
                    //Text Field To Enter Copyright
                    TextField("Copyright", text: $copyrightText)
                    //Label Tag Chips
                    HStack {
                        Text("Labels")
                        ChipsContent(viewModel: viewModel)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
        }
        //Set Navigation Bar Title To Label
        .navigationTitle("Label")
    }
    //Configuration Settings Section
    var config: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Configuration Management Table
                    //USE SWIFTUI TABLE COMPONENT
                    //Button To Export Marker Data Settings
                    Button(action: {}) {
                        Text("Export Marker Data Configurations")
                    }
                    //Button To Import Marker Data Settings
                    Button(action: {}) {
                        Text("Import Marker Data Configurations")
                    }
                    //Button To Load Default Marker Data Settings
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
    //Databases Settings Section
    var databases: some View {
        Form {
            HStack {
                VStack(alignment: .leading) {
                    //Connected Databases Table
                    //USE SWIFTUI TABLE COMPONENT
                    //Airtable Section
                    Text("Airtable")
                        .font(.title2)
                    HStack {
                        //Duplicate Airtable Template Button
                        Button(action: {}) {
                            Text("Duplicate Airtable Template")
                        }
                        .padding(.trailing)
                        //Find User API Key Button
                        Button(action: {}) {
                            Text("Find API Key")
                        }
                        .padding(.trailing)
                        //Find Base ID Button
                        Button(action: {}) {
                            Text("Find Base ID")
                        }
                    }
                    //Notion Section
                    Text("Notion")
                        .font(.title2)
                    HStack {
                        //Button To Duplicate Notion Template
                        Button(action: {}) {
                            Text("Duplicate Notion Template Button")
                        }
                        .padding(.trailing)
                        //Button To Find User Token
                        Button(action: {}) {
                            Text("Find Token")
                        }
                        .padding(.trailing)
                        //Button To Find Database URL
                        Button(action: {}) {
                            Text("Find Database URL")
                        }
                    }
                    .padding(.bottom)
                    //Button To Save Database Settings
                    Button(action: {}) {
                        Text("Save Database Settings")
                    }
                    //Button To Export Database Settings
                    Button(action: {}) {
                        Text("Export Database Settings")
                    }
                    //Button To Import Database Settings
                    Button(action: {}) {
                        Text("Import Database Settings")
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

//Chips View For Labels
struct Chips: View {
    //Chip Title
    let titleKey: LocalizedStringKey
    //Is It Selected
    @State var isSelected: Bool
    var body: some View {
        HStack {
            //Chip Title
            Text(titleKey)
            //Font Size
                .font(.title3)
                .lineLimit(1)
        }
        .padding(.all, 10)
        //Selected And Not Selected Colours
        .foregroundColor(isSelected ? .white : .accentColor)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 1.5))
        .onTapGesture {
            //Change Selected On Tap
            isSelected.toggle()
        }
    }
}

struct ChipsContent: View {
    @ObservedObject var viewModel = ChipsViewModel()
    var body: some View {
        //Declare View Height And Width Sizes
        var width = CGFloat.zero
        var height = CGFloat.zero
        return GeometryReader { geo in
                ZStack(alignment: .topLeading, content: {
                ForEach(viewModel.dataObject) { chipsData in
                    Chips(titleKey: chipsData.titleKey, isSelected: chipsData.isSelected)
                        .padding(.all, 5)
                        .alignmentGuide(.leading) { dimension in
                            if (abs(width - dimension.width) > geo.size.width) {
                                width = 0
                                height -= dimension.height
                            }
                            
                            let result = width
                            if chipsData.id == viewModel.dataObject.last!.id {
                                width = 0
                            } else {
                                width -= dimension.width
                            }
                            return result
                          }
                        .alignmentGuide(.top) { dimension in
                            let result = height
                            if chipsData.id == viewModel.dataObject.last!.id {
                                height = 0
                            }
                            return result
                        }
                }
            })
        }
        .padding(.all, 10)
    }
}

struct ChipsDataModel: Identifiable {
    let id = UUID()
    @State var isSelected: Bool
    let titleKey: LocalizedStringKey
}

class ChipsViewModel: ObservableObject {
    //Define Chips To Select
    @Published var dataObject: [ChipsDataModel] = [ChipsDataModel.init(isSelected: false, titleKey: "id"), ChipsDataModel.init(isSelected: false, titleKey: "clipName"), ChipsDataModel.init(isSelected: false, titleKey: "copyright"), ChipsDataModel.init(isSelected: false, titleKey: "clipDuration"), ChipsDataModel.init(isSelected: false, titleKey: "videoRole"), ChipsDataModel.init(isSelected: false, titleKey: "libraryName"), ChipsDataModel.init(isSelected: false, titleKey: "iconImage"), ChipsDataModel.init(isSelected: false, titleKey: "type"), ChipsDataModel.init(isSelected: false, titleKey: "checked"), ChipsDataModel.init(isSelected: false, titleKey: "audioRole"), ChipsDataModel.init(isSelected: false, titleKey: "imageFileName"), ChipsDataModel.init(isSelected: false, titleKey: "eventName"), ChipsDataModel.init(isSelected: false, titleKey: "projectName"), ChipsDataModel.init(isSelected: false, titleKey: "position"), ChipsDataModel.init(isSelected: false, titleKey: "notes")]
}
