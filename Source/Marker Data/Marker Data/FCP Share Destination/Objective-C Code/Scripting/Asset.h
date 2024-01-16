//
//  Asset.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Object.h"

// ------------------------------------------------------------
// Metadata Keys:
// ------------------------------------------------------------
extern const NSString*     kMetadataKeyManagedAsset;
extern const NSString*     kMetadataKeyPreparedAsset;
extern const NSString*     kMetadataKeyExpirationDate;

@interface Asset : Object

+ (BOOL)isMediaExtension:(NSString*)extension;
+ (BOOL)isDescExtension:(NSString*)extension;

// ------------------------------------------------------------
// init and dealloc:
// ------------------------------------------------------------
- (instancetype)init;
- (instancetype)init:(NSURL*)url;
- (instancetype)init:(NSString*)assetName at:(NSURL*)location media:(NSString*)mediaExt desc:(NSString*)descExt;
- (void)dealloc;

// ------------------------------------------------------------
// Properties:
// ------------------------------------------------------------
@property (nonatomic, readonly) NSURL* principalURL;
@property (nonatomic, readonly) NSURL* folderLocation;
@property (nonatomic, readwrite) NSString* mediaExtension;
@property (nonatomic, readwrite) NSString* descExtension;
@property (nonatomic, readonly) BOOL hasMedia;
@property (nonatomic, readonly) BOOL hasDescription;

// ------------------------------------------------------------
// A dictionary that contains base name, folder location,
// media extension, and description extension:
// ------------------------------------------------------------
@property (nonatomic, readonly) NSDictionary	*locationInfo;

@property (nonatomic, readonly) NSURL			*mediaFile;
@property (nonatomic, readonly) NSURL			*descFile;

@property (nonatomic, readwrite) NSDictionary   *metadata;
@property (nonatomic, readwrite) NSDictionary   *dataOptions;

- (void)loadMedia;
- (void)loadDescription;

// ------------------------------------------------------------
// Metadata & Data Options:
// ------------------------------------------------------------
- (void)addMetadata:(id)value forKey:(const NSString*)key;

- (void)setDataOption:(id)option forKey:(NSString*)key;
- (id)dataOptionForKey:(NSString*)key;

// ------------------------------------------------------------
// Convenience Properties:
// ------------------------------------------------------------
@property (readonly) NSString* duration;
@property (readonly) CGSize frameSize;
@property (readonly) NSString* frameDuration;

@property (readonly) NSString* episodeID;
@property (readonly) NSNumber* episodeNumber;

@property (readonly) BOOL mediaLoaded;
@property (readonly) BOOL descriptionLoaded;
@property (readonly) BOOL hasRoles;

@end
