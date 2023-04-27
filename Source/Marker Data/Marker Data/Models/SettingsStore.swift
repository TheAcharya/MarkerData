//
//  SettingsStore.swift
//  Marker Data
//
//  Created by Theo S on 27/04/2023.
//

import Foundation
import SwiftUI
import Combine

class SettingsStore: ObservableObject {
    @AppStorage("selectedExportFormat") private var selectedExportFormatRawValue: Int = ExportFormat.Notion.rawValue

    var selectedExportFormat: ExportFormat {
        get { ExportFormat(rawValue: selectedExportFormatRawValue) ?? .Notion }
        set { selectedExportFormatRawValue = newValue.rawValue }
    }

    @AppStorage("selectedExcludeRoles") private var selectedExcludeRolesRawValues: Int = ExcludedRoles.None.rawValue

    var selectedExcludeRoles: ExcludedRoles {
        get { ExcludedRoles(rawValue: selectedExcludeRolesRawValues) ?? .None }
        set { selectedExcludeRolesRawValues = newValue.rawValue }
    }


    @AppStorage("selectedImageMode") private var selectedImageModeRawValue: Int = ImageMode.PNG.rawValue

    var selectedImageMode: ImageMode {
        get { ImageMode(rawValue: selectedImageModeRawValue) ?? .PNG }
        set { selectedImageModeRawValue = newValue.rawValue }
    }
}
