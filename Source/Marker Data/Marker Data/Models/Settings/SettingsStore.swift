//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Peter Schorn
//

import Foundation
import SwiftUI
import Combine
import MarkersExtractor
import AppKit

class SettingsStore: ObservableObject {
    @AppStorage("exportFolderURL") var exportFolderURL: URL?

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
    
    
    @AppStorage("selectedIDNamingMode") private var selectedIDNamingModeRawValue: Int = IdNamingMode.Timecode.rawValue
    var selectedIDNamingMode: IdNamingMode {
        get { IdNamingMode(rawValue: selectedIDNamingModeRawValue) ?? .Name }
        set { selectedIDNamingModeRawValue = newValue.rawValue }
    }
    

    //Default Selected JPG Image Quality
    @AppStorage("selectedImageQuality") var selectedImageQuality: Int = 100

    //Default Image Width
    @AppStorage("imageWidth") var imageWidth: Int?  // 1920

    @AppStorage("imageWidthEnabled") var imageWidthEnabled = false

    //Default Image Height
    @AppStorage("imageHeight") var imageHeight: Int?  // 1080

    @AppStorage("imageHeightEnabled") var imageHeightEnabled = false

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
    var markersExtractorStrokeWidth: Int? {
        if selectedStrokeSize == 0 {
            return nil
        }
        
        return selectedStrokeSize
    }
    
    // Font color and opacity
    var selectedFontColor: Color {
        get {
            guard let hexString: String = UserDefaults.standard.string(forKey: "selectedFontColor") else {
                return .white
            }
            
            return Color(hex: hexString)
        }
        
        set(newColor) {
            UserDefaults.standard.set(newColor.hex, forKey: "selectedFontColor")
        }
    }
    
    var selectedFontColorOpacity: Double {
        get {
            UserDefaults.standard.double(forKey: "selectedFontColorOpacity")
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "selectedFontColorOpacity")
        }
    }
    
    // Stroke color
    var selectedStrokeColor: Color {
        get {
            guard let hexString: String = UserDefaults.standard.string(forKey: "selectedStrokeColor") else {
                return .white
            }
            
            return Color(hex: hexString)
        }
        
        set(newColor) {
            UserDefaults.standard.set(newColor.hex, forKey: "selectedStrokeColor")
        }
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
    
    var overlays: [ExportField] {
        get {
            // Safely get name array of overlay options
            guard let nameArray: [String] = UserDefaults.standard.stringArray(forKey: "selectedOverlays") else {
                return []
            }
            
            // Convert to array with optional types
            let optionalOverlayArray: [ExportField?] = nameArray.map { ExportField(rawValue: $0) }
            
            // Remove nil elements
            let overlayArray = optionalOverlayArray.compactMap { $0 }
            
            return overlayArray
        }
        
        set(newOverlays) {
            let nameArray = newOverlays.map { $0.rawValue }
            
            UserDefaults.standard.set(nameArray, forKey: "selectedOverlays")
        }
    }
    
    func flipOverlayState(overlay: ExportField) {
        if self.overlays.contains(overlay) {
            self.overlays = self.overlays.filter { $0 != overlay }
        } else {
            self.overlays = self.overlays + [overlay]
        }
    }
    
    @AppStorage("copyrightText") var copyrightText: String = ""
    
    @AppStorage("hideLabelNames") var hideLabelNames: Bool = false
    
    // MARK: CLI settings
    
    func markersExtractorSettings(fcpxmlFileUrl: URL) throws -> MarkersExtractor.Settings {
        let outputDirURL: URL = self.exportFolderURL ?? URL.moviesDirectory
        
        let settings = try MarkersExtractor.Settings(
            fcpxml: .init(at: fcpxmlFileUrl),
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
            includeOutsideClipBoundaries:  self.enabledClipBoundaries,
            excludeRoleType: self.selectedExcludeRoles.markersExtractor,
            imageLabels: self.overlays,
            imageLabelCopyright: self.copyrightText,
            imageLabelFont: self.selectedFontNameType.markersExtractor,
            imageLabelFontMaxSize: self.selectedFontSize,
            imageLabelFontOpacity: Int(self.selectedFontColorOpacity),
            imageLabelFontColor: self.selectedFontColor.hex,
            imageLabelFontStrokeColor: self.selectedStrokeColor.hex,
            imageLabelFontStrokeWidth: self.markersExtractorStrokeWidth,
            imageLabelAlignHorizontal: self.selectedHorizonalAlignment.markersExtractor,
            imageLabelAlignVertical: self.selectedVerticalAlignment.markersExtractor,
            imageLabelHideNames: self.hideLabelNames,
            //createDoneFile: Bool = Defaults.createDoneFile,
            //doneFilename: String = Defaults.doneFilename,
            exportFolderFormat: self.selectedFolderFormat.markersExtractor
            
        )
        
        return settings
        
    }
}