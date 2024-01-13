//
//  MediaAssetHelperKeys.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "MediaAssetHelperKeys.h"

// ------------------------------------------------------------
// CONSTANTS:
// ------------------------------------------------------------

// ------------------------------------------------------------
// The info plist key that indicate the application supports
// the protocol:
// ------------------------------------------------------------
const NSString*		kMediaAssetProtocolInfoKey	= @"com.apple.proapps.MediaAssetProtocol";

// ------------------------------------------------------------
// The asset location dictionary keys:
// ------------------------------------------------------------
const NSString*		kMediaAssetLocationFolderKey = @"folder";
const NSString*		kMediaAssetLocationBasenameKey = @"basename";
const NSString*		kMediaAssetLocationHasMediaKey = @"hasMedia";
const NSString*		kMediaAssetLocationHasDescriptionKey = @"hasDescription";

// ------------------------------------------------------------
// The asset data option dictionary keys:
// ------------------------------------------------------------
const NSString*     kMediaAssetDataOptionAvailableMetadataSetsKey = @"availableMetadataSets";
const NSString*     kMediaAssetDataOptionMetadataSetKey = @"metadataSet";
