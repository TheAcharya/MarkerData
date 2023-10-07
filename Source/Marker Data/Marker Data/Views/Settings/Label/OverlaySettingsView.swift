//
//  OverlaySettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 06/10/2023.
//

import SwiftUI
import MarkersExtractor

struct OverlaySettingsView: View {
    @EnvironmentObject var settingsStore: SettingsStore

    @State private var searchText = ""
    @State private var selectedTags: Set<String> = []

    /// Loaded in bady onAppear
    @State var overlays: [OverlayItem] = []

    var filteredOverlays: [OverlayItem] {
        overlays.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var enabledOverlays: [OverlayItem] {
        filteredOverlays.filter {
            $0.isSelected
        }
    }

    var disabledOverlays: [OverlayItem] {
        filteredOverlays.filter {
            !$0.isSelected
        }
    }

    var body: some View {
        VStack {
            TextField("Search Overlays", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)

            HStack(alignment: .top) {
                overlayListView(
                    title: "Disabled Overlays",
                    overlays: disabledOverlays
                )

                Spacer()

                overlayListView(
                    title: "Enabled Overlays",
                    overlays: enabledOverlays
                )
            }
//            .frame(maxHeight: 200)

            Divider()
                .padding(.vertical)

            VStack(alignment: .leading) {
                HStack {
                    Text("Copyright:")
                    TextField("Your company", text: settingsStore.$copyrightText)
                }

                HStack {
                    Text("Hide Label Names:")
                    Toggle("", isOn: settingsStore.$hideLabelNames)
                }
            }
            .padding(.bottom)
        }
        .frame(maxWidth: 520)
        .onAppear {
            let selectedOverlays = settingsStore.overlays

            overlays = ExportField.allCases.map {
                OverlayItem(overlay: $0,
                            isSelected: selectedOverlays.contains($0))
            }
        }
    }

    func overlayListView(title: String, overlays: [OverlayItem]) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20, weight: .bold))

            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(overlays) { overlay in
                        Button(overlay.name) {
                            withAnimation(.spring(duration: 0.2)) {
                                if let index = self.overlays.firstIndex(of: overlay) {
                                    self.overlays[index].flipSelection(settingsStore: settingsStore)
                                }
                            }
                        }
                    }
                }
                .frame(width: 200, alignment: .leading)
            }
        }
    }
}

#Preview {
    @StateObject var settingsStore = SettingsStore()
    
    return OverlaySettingsView()
        .padding()
        .environmentObject(settingsStore)
}
