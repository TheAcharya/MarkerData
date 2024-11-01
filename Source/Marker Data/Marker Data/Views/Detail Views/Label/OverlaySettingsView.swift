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

    var filteredOverlays: [ExportField] {
        ExportField.allCases.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var enabledOverlays: [ExportField] {
        filteredOverlays.filter {
            settings.store.overlays.contains($0)
        }
    }

    var disabledOverlays: [ExportField] {
        filteredOverlays.filter {
            !settings.store.overlays.contains($0)
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
    }
    
    var copyrightAndHideLabelNames: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Copyright:")
                TextField("Input your copyright information", text: $settings.store.copyrightText)
            }

            HStack {
                Text("Hide Label Names:")
                Toggle("", isOn: $settings.store.hideLabelNames)
            }
        }
    }

    func overlayListView(title: String, overlays: [ExportField], clear: (() -> Void)? = nil) -> some View {
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
                                    // Remove
                                    if let index = settings.store.overlays.firstIndex(of: overlay) {
                                        settings.store.overlays.remove(safeAt: index)
                                    }
                                    // Add
                                    else {
                                        settings.store.overlays.append(overlay)
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
    let settings = SettingsContainer()

    return OverlaySettingsView()
        .padding()
        .environmentObject(settings)
}
