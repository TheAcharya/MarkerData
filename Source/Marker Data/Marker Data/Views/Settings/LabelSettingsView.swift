//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import SwiftUI
import Foundation
import MarkersExtractor


struct LabelSettingsView: View {
    @EnvironmentObject var settigsStore: SettingsStore
    
    @State private var searchText = ""
    @State private var selectedTags: Set<String> = []
    
    var filteredLabels: [String] {
        let labels = ExportField.allCases.map { $0.name }
        
        return labels.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    @State var isOn = false

    var body: some View {
        VStack {
            TextField("Search Labels", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            List(filteredLabels, id: \.self) { tag in
                Toggle(isOn: $isOn) {
                    Text(tag)
                }
                .toggleStyle(.button)
//                .listRowSeparator(.hidden)
//                .padding(.vertical, 3)
//                .buttonStyle(.borderedProminent)
            }
            .listStyle(.sidebar)
        }
    }
}


// START OF LIST STYLE APPROACH

//struct Item: Identifiable, Hashable {
//    let id = UUID()
//    let name: String
//}
//
//struct LabelSettingsView: View {
//    @State private var items = [
//        Item(name: "Tag 1"),
//        Item(name: "Tag 2"),
//        Item(name: "Tag 3"),
//        Item(name: "Tag 4"),
//        Item(name: "Tag 5")
//    ]
//    @State private var selectedItems = Set<Item>()
//    @State private var searchText = ""
//
//    var body: some View {
//        VStack {
//            SearchBar(text: $searchText)
//            List(selection: $selectedItems) {
//                ForEach(items.filter({ searchText.isEmpty || $0.name.localizedStandardContains(searchText) })) { item in
//                    Text(item.name)
//                }
//                .onDelete(perform: deleteItems)
//            }
//        }
//    }
//
//    func deleteItems(at offsets: IndexSet) {
//        items.remove(atOffsets: offsets)
//    }
//}
//
//struct SearchBar: View {
//    @Binding var text: String
//
//    var body: some View {
//        HStack {
//            TextField("Search", text: $text)
//                .padding(.leading, 24)
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.gray)
//                .padding(.leading, 8)
//            if !text.isEmpty {
//                Button(action: { text = "" }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .padding(8)
//        .background(Color(.gray))
//        .cornerRadius(8)
//    }
//}

// END OF LIST STYLE APPROACH


//struct LabelSettingsView: View {
//
//    enum Section: String, CaseIterable, Identifiable {
//        case general, token
//
//        var id: String { self.rawValue }
//
//    }
//
//    @State private var section = Section.token
//
//    var body: some View {
//
//        VStack {
//            Picker("", selection: $section) {
//                ForEach(Section.allCases) { section in
//                    Text(section.rawValue)
//                        .tag(section)
//                }
//            }
//            .pickerStyle(.segmented)
//            .frame(width: 200)
//            .padding(10)
//            // .border(.green)
//
//            Group {
//                switch section {
//                    case .general:
//                        GeneralLabelSettingsView()
//                    case .token:
//                        TokenLabelSettingsView()
//                }
//            }
//            // .border(.green)
//
//            Spacer()
//
//        }
//
//        // TabView {
//        //     GeneralLabelSettingsView()
//        //         .tabItem {
//        //             Text("General")
//        //         }
//        //
//        //     TokenLabelSettingsView()
//        //         .tabItem {
//        //             Text("Token")
//        //         }
//        // }
//        // .tabViewStyle(.automatic)
//    }
//
//}

struct LabelSettingsView_Previews: PreviewProvider {

    @StateObject static private var settingsStore = SettingsStore()

    static var previews: some View {
        LabelSettingsView()
            .environmentObject(settingsStore)
    }
}
