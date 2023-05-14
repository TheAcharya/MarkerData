//
//  SettingsView.swift
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//

import SwiftUI
import FontPicker

struct SettingsView: View {
    
    //Main Settings View Controller
    var body: some View {
        if #available(macOS 13.0, *) {
            NavigationSplitView {
                List {
                    //Link To General Settings
                    NavigationLink(destination: GeneralSettingsView()) {
                        Label("General", systemImage: "gearshape")
                    }
                    //Link To Image Settings
                    NavigationLink(destination: ImageSettingsView()) {
                        Label("Image", systemImage: "photo")
                    }
                    //Link To Label Settings
                    NavigationLink(destination: LabelSettingsView()) {
                        Label("Label", systemImage: "tag")
                    }
                    //Link To Configuration Settings
                    NavigationLink(destination: ConfigurationSettingsView()) {
                        Label("Configuration", systemImage: "slider.vertical.3")
                    }
                    //Link To Database Settings
                    NavigationLink(destination: DatabaseSettingsView()) {
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
            .frame(width: 700, height: 500)
            //Hide Toolbar
            .toolbar(.hidden)
        } else {
            // Fallback On Earlier Versions
            NavigationView {
                List {
                    //Link To General Settings
                    NavigationLink(destination: GeneralSettingsView()) {
                        Label("General", systemImage: "gearshape")
                    }
                    //Link To Image Settings
                    NavigationLink(destination: ImageSettingsView()) {
                        Label("Image", systemImage: "photo")
                    }
                    //Link To Label Settings
                    NavigationLink(destination: LabelSettingsView()) {
                        Label("Label", systemImage: "tag")
                    }
                    //Link To Configuration Settings
                    NavigationLink(destination: ConfigurationSettingsView()) {
                        Label("Configuration", systemImage: "slider.vertical.3")
                    }
                    //Link To Database Settings
                    NavigationLink(destination: DatabaseSettingsView()) {
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
            .frame(width: 700, height: 500)
        }
    }

}

struct SettingsView_Previews: PreviewProvider {
    static let settingsStore = SettingsStore()
    static var previews: some View {
        SettingsView().environmentObject(settingsStore)
    }
}
/*
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

*/
