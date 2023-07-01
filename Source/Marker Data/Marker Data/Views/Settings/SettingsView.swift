//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) var viewContext

    @EnvironmentObject var settingsStore: SettingsStore
    
    //Main Settings View Controller
    var body: some View {
        Group {
            if #available(macOS 13.0, *) {
                NavigationSplitView(
                    sidebar: { sidebarView },
                    detail: { detailView }
                )
                // only available in macOS 13+
                .toolbar(.hidden)
            } else {
                // Fallback On Earlier Versions
                NavigationView {
                    sidebarView
                    
                    //Show App Icon And App Title When No Setting Section Is Selected
                    detailView
                }
            }
        }
        // Set Settings Window Static Width And Height
        .frame(width: 700, height: 500)
    }

    var sidebarView: some View {
        List(
            SettingsSection.allCases,
            selection: $settingsStore.settingsSection
        ) { section in

            Group {
                switch section {
                    case .general:
                        Label("General", systemImage: "gearshape")
                            .tag(SettingsSection.general)

                    case .image:
                        Label("Image", systemImage: "photo")
                            .tag(SettingsSection.image)

                    case .label:
                        Label("Label", systemImage: "tag")
                            .tag(SettingsSection.label)

                    case .configurations:
                        Label("Configurations", systemImage: "briefcase")
                            .tag(SettingsSection.configurations)

                    case .databases:
                        Label("Databases", systemImage: "server.rack")
                            .tag(SettingsSection.databases)

                    case .about:
                        Label("About", systemImage: "info.circle")
                            .tag(SettingsSection.about)

                }
            }
            .padding(.vertical, 5)

        }
        .listStyle(.sidebar)
        .modify { view in
            if #available(macOS 13.0, *) {
                view
                    .navigationSplitViewColumnWidth(190)
            }
            else {
                view
            }
        }

    }

    @ViewBuilder var detailView: some View {
        // Show App Icon And App Title When No Setting Section Is Selected
        // AboutView()
        // LabelSettingsView()
        // ImageSettingsView()
        switch settingsStore.settingsSection {
            case .general:
                GeneralSettingsView()
            case .image:
                ImageSettingsView()
            case .label:
                LabelSettingsView()
            case .configurations:
                ConfigurationSettingsView()
            case .databases:
                DatabaseSettingsView()
            case .about, nil:
                AboutView()
        }
    }

    
}

struct SettingsView_Previews: PreviewProvider {

    @StateObject static private var settingsStore = SettingsStore()

    static var previews: some View {
        SettingsView()
            .environmentObject(settingsStore)
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
