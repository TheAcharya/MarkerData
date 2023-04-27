//
//  ExportFormatPicker.swift
//  Marker Data
//
//  Created by Theo S on 26/04/2023.
//

import SwiftUI

struct ExportFormatPicker: View {
    @EnvironmentObject var exportFormatStore: ExportFormatStore

    var body: some View {
        Picker("Export Format", selection: $exportFormatStore.selectedExportFormat) {
            ForEach(ExportFormat.allCases, id: \.self) { exportFormat in
                Text(exportFormat.displayName).tag(exportFormat)
            }
        }
    }
}

struct ExcludedRolesPicker: View {
    @EnvironmentObject var excludedRolesStore: ExcludedRolesStore

    var body: some View {
        Picker("Exclude Roles", selection: $excludedRolesStore.selectedExcludeRoles) {
            ForEach(ExcludedRoles.allCases, id: \.self) { excludedRole in
                Text(excludedRole.displayName).tag(excludedRole)
            }
        }
    }
}

struct ImageModePicker: View {
    @EnvironmentObject var imageModeStore: ImageModeStore

    var body: some View {
        Picker("Image Mode", selection: $imageModeStore.selectedImageMode) {
            ForEach(ImageMode.allCases, id: \.self) { imageMode in
                Text(imageMode.displayName).tag(imageMode)
            }
        }
    }
}
