//
//  Marker Data • https://github.com/TheAcharya/MarkerData
//  Licensed under MIT License
//
//  Maintained by Milán Várady
//

import Foundation
import SwiftUI
import MarkersExtractor

struct SettingsStore: Codable, Hashable, Equatable, Identifiable {
    /// Used for versioning
    static var version: Int = 3
    var version: Int = Self.version

    var name: String

    var id: String {
        self.name
    }

    var jsonURL: URL {
        return URL.configurationsFolder
            .appendingPathComponent(self.name, conformingTo: .json)
    }

    static let defaultName = "Default"

    var unifiedExportProfile: UnifiedExportProfile

    var exportFolderURL: URL?
    var folderFormat: ExportFolderFormat

    var imageMode: ImageMode
    var enabledSubframes: Bool
    var includeDisabledClips: Bool
    var enabledNoMedia: Bool

    var IDNamingMode: MarkerIDMode
    var markersSource: MarkersSource

    // MARK: Overall image size settings

    // If .noOverride image size, image width andd image hight will be ignored
    var overrideImageSize: OverrideImageSizeOption
    
    // Will be ignored if override image size is off
    var imageSizePercent: Int

    // Will be ignored if override image size is off
    var imageWidth: Int

    // Will be ignored if override image size is off
    var imageHeight: Int
    
    // MARK: Image file type specific settings
    var JPEGImageQuality: Int
    var GIFFPS: Int
    var GIFLength: Int

    var fontNameType: FontNameType
    var fontStyleType: FontStyleType
    
    var fontSize: Int

    var strokeSize: Int
    var isStrokeSizeAuto: Bool
    
    // Font color and opacity
    var fontColor: Color
    var fontColorOpacity: Double

    // Stroke color
    var strokeColor: Color
    
    var overlays: [ExportField]

    mutating func flipOverlayState(overlay: ExportField) {
        if self.overlays.contains(overlay) {
            self.overlays = self.overlays.filter { $0 != overlay }
        } else {
            self.overlays = self.overlays + [overlay]
        }
    }

    var horizonalAlignment: MarkerLabelProperties.AlignHorizontal
    var verticalAlignment: MarkerLabelProperties.AlignVertical

    var copyrightText: String
    var hideLabelNames: Bool

    var roles: [RoleModel]

    // MARK: Progress reporting settings

    var notificationFrequency: NotificationFrequency
    var showDockProgress: Bool

    // MARK: Color swatch
    var colorSwatchSettings: ColorSwatchSettingsModel

    /// Default settings
    public static func defaults() -> Self {
        let exportProfile = UnifiedExportProfile(
            displayName: "CSV",
            extractProfile: .csv,
            databaseProfileName: "",
            exportProfileType: .extractOnly
        )

        return Self.init(
            name: Self.defaultName,
            unifiedExportProfile: exportProfile,
            folderFormat: .medium,
            imageMode: .PNG,
            enabledSubframes: false,
            includeDisabledClips: false, 
            enabledNoMedia: false,
            IDNamingMode: .projectTimecode,
            markersSource: .markers,
            overrideImageSize: .noOverride,
            imageSizePercent: 100,
            imageWidth: 1920,
            imageHeight: 1080,
            JPEGImageQuality: 100,
            GIFFPS: 10,
            GIFLength: 2,
            fontNameType: .menlo,
            fontStyleType: .regular,
            fontSize: 30,
            strokeSize: 0,
            isStrokeSizeAuto: true,
            fontColor: .white,
            fontColorOpacity: 100,
            strokeColor: .black,
            overlays: [],
            horizonalAlignment: .left,
            verticalAlignment: .top,
            copyrightText: "",
            hideLabelNames: false,
            roles: [],
            notificationFrequency: .onlyOnCompletion,
            showDockProgress: true,
            colorSwatchSettings: .defaults()
        )
    }

    // MARK: CLI settings

    /// Returns the settings needed for a ``MarkersExtractor`` object
    public func markersExtractorSettings(fcpxmlFileUrl: URL) throws -> MarkersExtractor.Settings {
        // Output dir
        let outputDirURL: URL = self.exportFolderURL ?? URL.FCPExportCacheFolder
        
        // Exclude roles
        let excludeRoles = self.roles.filter { !$0.enabled }
        let excludeRoleNames: Set<String> = Set(excludeRoles.map { $0.role.rawValue })
        
        // Image size override
        var imageWidth: Int? = nil
        var imageHeight: Int? = nil
        var imageSizePercent: Int? = nil
        
        switch self.overrideImageSize {
        case .noOverride:
            // If using GIF default to 50% image size
            if self.imageMode == .GIF {
                imageSizePercent = 50
            }
        case .overrideImageSizePercent:
            imageSizePercent = self.imageSizePercent
        case .overrideImageWidthAndHeight:
            imageWidth = self.imageWidth
            imageHeight = self.imageHeight
        }
        
        // Stroke size
        let strokeSize: Int? = self.isStrokeSizeAuto ? nil : self.strokeSize

        let settings = try MarkersExtractor.Settings(
            fcpxml: .init(at: fcpxmlFileUrl),
            outputDir: outputDirURL,
            exportFormat: self.unifiedExportProfile.extractProfile,
            enableSubframes: self.enabledSubframes,
            markersSource: self.markersSource,
            excludeRoles: excludeRoleNames,
            includeDisabled: self.includeDisabledClips, 
            imageFormat: self.imageMode.markersExtractor,
            imageQuality: Int(self.JPEGImageQuality),
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            imageSizePercent: imageSizePercent,
            gifFPS: Double(self.GIFFPS),
            gifSpan: TimeInterval(self.GIFLength),
            idNamingMode: self.IDNamingMode,
            imageLabels: self.overlays,
            imageLabelCopyright: self.copyrightText,
            imageLabelFont: self.fontNameType.markersExtractor,
            imageLabelFontMaxSize: self.fontSize,
            imageLabelFontOpacity: Int(self.fontColorOpacity).clamped(to: 0...100),
            imageLabelFontColor: self.fontColor.hex,
            imageLabelFontStrokeColor: self.strokeColor.hex,
            imageLabelFontStrokeWidth: strokeSize,
            imageLabelAlignHorizontal: self.horizonalAlignment,
            imageLabelAlignVertical: self.verticalAlignment,
            imageLabelHideNames: self.hideLabelNames,
            exportFolderFormat: self.folderFormat
        )
        
        return settings
    }

    public func saveAsConfiguration() async throws {
        try await self.save(at: jsonURL)
    }

    public func saveAsCurrent() async throws {
        try await self.save(at: URL.preferencesJSON)
    }

    private func save(at url: URL) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(self)

        try data.write(to: url)
    }

    public func delete() throws {
        try jsonURL.trashOrDelete()
    }

    public func isDefault() -> Bool {
        return self.name == Self.defaultName
    }
}
