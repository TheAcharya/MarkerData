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
import AppKit

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
            gifFPS: Double(self.selectedGIFFPS),
            gifSpan: TimeInterval(self.selectedGIFLength),
            idNamingMode: self.selectedIDNamingMode.markersExtractor,
            //includeOutsideClipBoundaries:  self.

            excludeRoleType: self.selectedExcludeRoles.markersExtractor,
           // imageLabels: []
            imageLabelCopyright: self.copyrightText,
            imageLabelFont: self.selectedFontNameType.markersExtractor,
            imageLabelFontMaxSize: self.selectedFontSize,
//            imageLabelFontOpacity: Int = Defaults.imageLabelFontOpacity,
            imageLabelFontColor: self.selectedFontHexColor,
            imageLabelFontStrokeColor: self.selectedStrokeHexColor,
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
    
    @AppStorage("selectedFolderFormat") private var selectedFolderFormatRawValue: Int = UserFolderFormat.Medium.rawValue
    var selectedFolderFormat: UserFolderFormat{
        get { UserFolderFormat(rawValue: selectedFolderFormatRawValue) ?? .Medium }
        set { selectedFolderFormatRawValue = newValue.rawValue }
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
    
    @AppStorage("enabledClipBoundaries") var enabledClipBoundaries = false
    @AppStorage("enabledNoMedia") var enabledNoMedia = false
    
    
    
    @AppStorage("selectedIDNamingMode") private var selectedIDNamingModeRawValue:Int = IdNamingMode.Timecode.rawValue
    var selectedIDNamingMode: IdNamingMode {
        get { IdNamingMode(rawValue: selectedIDNamingModeRawValue) ?? .Name }
        set { selectedIDNamingModeRawValue = newValue.rawValue }
    }
    
    //Default Selected JPG Image Quality
    @AppStorage("selectedImageQuality") var selectedImageQuality: Int = 100
    //Default Image Width
    @AppStorage("imageWidth") var imageWidth: Int = 1920
    //Default Image Height
    @AppStorage("imageHeight") var imageHeight: Int = 1080
    //Default Image Scale Size
    @AppStorage("selectedImageSize") var selectedImageSize: Int = 100
    //Default Set GIF FPS
    @AppStorage("selectedGIFFPS") var selectedGIFFPS: Int = 10
    //Default Set GIF Length Span
    @AppStorage("selectedGIFLength") var selectedGIFLength: Int = 2
    //Default Selected Font
    @AppStorage("selectedFontNameType") private var selectedFontNameTypeRawValue: Int = FontNameType.Menlo.rawValue
    var selectedFontNameType: FontNameType {
        get { FontNameType(rawValue: selectedFontNameTypeRawValue) ?? .Menlo }
        set { selectedFontNameTypeRawValue = newValue.rawValue }
    }
    
    @AppStorage("selectedFontStyleType") private var selectedFontStyleTypeRawValue: Int = FontStyleType.Regular.rawValue
    var selectedFontStyleType: FontStyleType {
        get { FontStyleType(rawValue: selectedFontStyleTypeRawValue) ?? .Regular }
        set { selectedFontStyleTypeRawValue = newValue.rawValue }
    }
    
    var selectFontNameStyle: String {
        let name = self.selectedFontNameType.markersExtractor + "-" + selectedFontStyleType.markersExtractor
        return name
    }
    
    @AppStorage("selectedFontSize") var selectedFontSize: Int = 30
    @AppStorage("selectedStrokeSize") var selectedStrokeSize: Int = 0
    
    
    @AppStorage("selectedFontColorRed") var selectedFontColorRed: Double = 1.0
    @AppStorage("selectedFontColorGreen") var selectedFontColorGreen: Double = 1.0
    @AppStorage("selectedFontColorBlue") var selectedFontColorBlue: Double = 1.0
    @AppStorage("selectedFontColorOpacity") var selectedFontColorOpacity: Double = 100.0
    var selectedFontColor: Color {
        get { Color(red: selectedFontColorRed, green: selectedFontColorGreen, blue: selectedFontColorBlue, opacity: selectedFontColorOpacity) }
        set {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var o: CGFloat = 0
            NSColor(newValue).getRed(&r, green: &g, blue: &b, alpha:&o)
            
            selectedFontColorRed = Double(r)
            selectedFontColorGreen = Double(g)
            selectedFontColorBlue = Double(b)
            selectedFontColorOpacity = Double(o)
            
            print("color = \(selectedFontHexColor)")
        }
    }
    var selectedFontHexColor: String {
        let hex = String(format:  "#%02X%02X%02X", Int(selectedFontColorRed*255), Int(selectedFontColorGreen*255), Int(selectedFontColorBlue*255))
        return hex
    }
    var selectedFontOpacityHexColor: String {
        let hex = String(format:  "#%02", Int(selectedFontColorOpacity*255))
        return hex
    }
    
    @AppStorage("selectedStrokeColorRed") var selectedStrokeColorRed: Double = 1.0
    @AppStorage("selectedStrokeColorGreen") var selectedStrokeColorGreen: Double = 1.0
    @AppStorage("selectedStrokeColorBlue") var selectedStrokeColorBlue: Double = 1.0
    @AppStorage("selectedStrokeColorOpacity") var selectedStrokeColorOpacity: Double = 100.0
    var selectedStrokeColor: Color {
        get { Color(red: selectedStrokeColorRed, green: selectedStrokeColorGreen, blue: selectedStrokeColorBlue, opacity: selectedStrokeColorOpacity) }
        set {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var o: CGFloat = 0
            NSColor(newValue).getRed(&r, green: &g, blue: &b, alpha:&o)
            
            selectedStrokeColorRed = Double(r)
            selectedStrokeColorGreen = Double(g)
            selectedStrokeColorBlue = Double(b)
            selectedStrokeColorOpacity = Double(o)
        }
    }
    var selectedStrokeHexColor: String {
        let hex = String(format:  "#%02X%02X%02X", Int(selectedStrokeColorRed*255), Int(selectedStrokeColorGreen*255), Int(selectedStrokeColorBlue*255))
        return hex
    }
    var selectedStrokeOpacityHexColor: String {
        let hex = String(format:  "#%02", Int(selectedStrokeColorOpacity*255))
        return hex
    }

    


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
    
    
    @AppStorage("overlays") var overlaysText = ""
    @AppStorage("copyrightText") var copyrightText = ""
    
    @AppStorage("hideLabelNames") var hideLabelNames = false
    
    
}