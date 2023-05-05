//
//  SettingsStore.swift
//  Marker Data
//
//  Created by Theo S on 27/04/2023.
//

import Foundation
import SwiftUI
import Combine
import MarkersExtractor

class SettingsStore: ObservableObject {
    func markersExtractorSettings(fcpxmlFileUrl: URL) throws -> MarkersExtractor.Settings {
        let outputDirURL: URL = UserDefaults.standard.exportFolder
        let settings = try MarkersExtractor.Settings(
            fcpxml: .init(fcpxmlFileUrl),
            outputDir: outputDirURL,
            exportFormat: self.selectedExportFormat.markersExtractor,
            enableSubframes: self.enabledSubframes,
            imageFormat: self.selectedImageMode.markersExtractor,
            imageQuality: Int(self.selectedImageQuality),
            imageWidth: self.imageWidth,
            imageHeight: self.imageHeight,
            imageSizePercent: Int(self.selectedImageSize),
            gifFPS: self.selectedGIFFPS,
            gifSpan: self.selectedGIFLength,
            idNamingMode: self.selectedIDNamingMode.markersExtractor,
            //includeOutsideClipBoundaries:  self.

            excludeRoleType: self.selectedExcludeRoles.markersExtractor,
           // imageLabels: []
            imageLabelCopyright: self.copyrightText,
//            imageLabelFont: String = Defaults.imageLabelFont,
//            imageLabelFontMaxSize: Int = Defaults.imageLabelFontMaxSize,
//            imageLabelFontOpacity: Int = Defaults.imageLabelFontOpacity,
//            imageLabelFontColor: String = Defaults.imageLabelFontColor,
//            imageLabelFontStrokeColor: String = Defaults.imageLabelFontStrokeColor,
//            imageLabelFontStrokeWidth: Int? = Defaults.imageLabelFontStrokeWidth,
            imageLabelAlignHorizontal: self.selectedHorizonalAlignment.markersExtractor,
            imageLabelAlignVertical: self.selectedVerticalAlignment.markersExtractor
            //imageLabelHideNames: Bool = Defaults.imageLabelHideNames,
            //createDoneFile: Bool = Defaults.createDoneFile,
            //doneFilename: String = Defaults.doneFilename,
            //exportFolderFormat: ExportFolderFormat = Defaults.exportFolderFormat
            
        )
        
        return settings
        
    }
    
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
    @AppStorage("isUploadEnabled") var isUploadEnabled = false
    
    //Are Subframes Enabled
    @AppStorage("enabledSubframes") var enabledSubframes = false
    
    @AppStorage("selectedIDNamingMode") private var selectedIDNamingModeRawValue:Int = IdNamingMode.Timecode.rawValue
    var selectedIDNamingMode: IdNamingMode {
        get { IdNamingMode(rawValue: selectedIDNamingModeRawValue) ?? .Name }
        set { selectedIDNamingModeRawValue = newValue.rawValue }
    }
    
    //Default Selected JPG Image Quality
    @AppStorage("selectedImageQuality") var selectedImageQuality = 100.0
    //Default Image Width
    @AppStorage("imageWidth") var imageWidth: Int = 1920
    //Default Image Height
    @AppStorage("imageHeight") var imageHeight: Int = 1080
    //Default Image Scale Size
    @AppStorage("selectedImageSize") var selectedImageSize: Double = 100.0
    //Default Set GIF FPS
    @AppStorage("selectedGIFFPS") var selectedGIFFPS:Double = 10
    //Default Set GIF Length Span
    @AppStorage("selectedGIFLength") var selectedGIFLength: TimeInterval = 2
    //Default Selected Font
    @AppStorage("selectedFontName") var selectedFontName: String = NSFont.init(name: "Menlo-Regular", size: 30)!.fontName
    @AppStorage("selectedFontSize") var selectedFontSize: Double = 30
    
//    var selectedFont: NSFont {
//        NSFont(name: selectedFontName, size: selectedFontSize) ?? NSFont.systemFont(ofSize: selectedFontSize)
//    }
//
//    func updateSelectedFont(_ newFont: NSFont) {
//        selectedFontName = newFont.fontName
//        selectedFontSize = newFont.pointSize
//    }
    
    @AppStorage("selectedHorizontalAlignment") private var selectedHorizonalAlignmentRawValue: Int = LabelHorizontalAlignment.Left.rawValue
    var selectedHorizonalAlignment: LabelHorizontalAlignment {
        get { LabelHorizontalAlignment(rawValue: selectedHorizonalAlignmentRawValue) ?? .Left }
        set { selectedHorizonalAlignmentRawValue = newValue.rawValue }
    }
    
    @AppStorage("selectedVerticallignment") private var selectedVerticalAlignmentRawValue: Int = LabelVerticalAlignment.Top.rawValue
     var selectedVerticalAlignment: LabelVerticalAlignment {
        get { LabelVerticalAlignment(rawValue: selectedVerticalAlignmentRawValue) ?? .Top }
        set { selectedVerticalAlignmentRawValue = newValue.rawValue }
    }
    @AppStorage("copyrightText") var copyrightText = ""
    
}
