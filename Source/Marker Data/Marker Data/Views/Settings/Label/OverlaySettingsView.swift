//
//  OverlaySettingsView.swift
//  Marker Data
//
//  Created by Milán Várady on 06/10/2023.
//

import SwiftUI
import MarkersExtractor

struct OverlaySettingsView: View {
    @EnvironmentObject var settings: SettingsContainer

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
            overlaySelectionField

            Divider()
                .padding(.vertical)

            copyrightAndHideLabelNames
                .padding(.bottom)
        }
        .frame(maxWidth: 520)
        .onAppear {
            let selectedOverlays = settings.store.overlays

            overlays = ExportField.allCases.map {
                OverlayItem(overlay: $0,
                            isSelected: selectedOverlays.contains($0))
            }
        }
    }
    
    var overlaySelectionField: some View {
        VStack {
            TextField("Search Overlays", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
            
            HStack(alignment: .top) {
                overlayListView(
                    title: "Available Overlays",
                    overlays: disabledOverlays
                )
                
                Spacer()
                
                overlayListView(
                    title: "Selected Overlays",
                    overlays: enabledOverlays,
                    clear: removeActiveOverlays
                )
            }
        }
    }
    
    func removeActiveOverlays() {
        settings.store.overlays.removeAll()
        self.overlays = ExportField.allCases.map {
            OverlayItem(overlay: $0,
                        isSelected: false)
        }
    }
    
    var copyrightAndHideLabelNames: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Copyright:")
                TextField("Your company", text: $settings.store.copyrightText)
            }

            HStack {
                Text("Hide Label Names:")
                Toggle("", isOn: $settings.store.hideLabelNames)
            }
        }
    }

    func overlayListView(title: String, overlays: [OverlayItem], clear: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading) {
            VStack {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical, 6)
            }
            .frame(maxWidth: .infinity)
            .background(.quinary)

            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(overlays) { overlay in
                            Button(overlay.name) {
                                withAnimation(.spring(duration: 0.2)) {
                                    if let index = self.overlays.firstIndex(of: overlay) {
                                        self.overlays[index].flipSelection(settings: settings)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            
            if clear != nil {
                VStack(alignment: .trailing) {
                    Button {
                        clear?()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 5)
                    .padding(.trailing, 5)
                    .help("Remove Selected Overlays")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    @StateObject var settings = SettingsContainer()
    
    return OverlaySettingsView()
        .padding()
        .environmentObject(settings)
}
