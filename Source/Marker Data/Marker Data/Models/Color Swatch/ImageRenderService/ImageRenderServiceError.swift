//
//  ImageServiceError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 31.08.2023.
//

import Foundation

enum ImageRenderServiceError: Error {
    case stripRender
    case mergeImageWithStrip
    case map(errorDescription: String?, recoverySuggestion: String?)
    case colorsIsEmpty
}

extension ImageRenderServiceError: LocalizedError {
    var errorDescription: String? {
        let comment = "Image service error"
        switch self {
        case .stripRender:
            return NSLocalizedString("Unable to render stripe image", comment: comment)
        case .mergeImageWithStrip:
            return NSLocalizedString("Failed to merge image and strip", comment: comment)
        case .map(let errorDescription, _):
            return NSLocalizedString(errorDescription ?? "Unknown error", comment: comment)
        case .colorsIsEmpty:
            return NSLocalizedString("Strip colors not found or could not be createde", comment: comment)
        }
    }
    
    var recoverySuggestion: String? {
        let comment = "Image service error"
        switch self {
        case .stripRender, .mergeImageWithStrip:
            return NSLocalizedString("Try again.", comment: comment)
        case .map(_, let recoverySuggestion):
            return NSLocalizedString(recoverySuggestion ?? "Unknown reaction", comment: comment)
        case .colorsIsEmpty:
            return NSLocalizedString("Try exporting the image separately", comment: comment)
        }
    }
}
