//
//  MediaAssetHelperKeys.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#pragma once

#import <Foundation/Foundation.h>

// ------------------------------------------------------------
// Bundle plist keys:
// ------------------------------------------------------------
extern NSString*        kMediaAssetProtocolInfoKey;

// ------------------------------------------------------------
// Asset location dictionary keys:
// ------------------------------------------------------------
extern NSString*		kMediaAssetLocationFolderKey;					// Destination folder
extern NSString*		kMediaAssetLocationBasenameKey;					// Base Name
extern NSString*		kMediaAssetLocationHasMediaKey;					// Boolean indicating need for media export
extern NSString*		kMediaAssetLocationHasDescriptionKey;			// Boolean indicating need for xml export

// ------------------------------------------------------------
// Data option dictionary keys:
// ------------------------------------------------------------
extern NSString*		kMediaAssetDataOptionAvailableMetadataSetsKey;	// NSArray of available metadata view set names
extern NSString*		kMediaAssetDataOptionMetadataSetKey;			// NSString of desired metadata view set

