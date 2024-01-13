//
//  Document.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#pragma once

#import <Cocoa/Cocoa.h>
#import "Object.h"
#import "Asset.h"
#import "WindowController.h"

@interface Document : NSDocument

@property (readonly) WindowController*    primaryWindowController;

// ------------------------------------------------------------
// Properties:
// ------------------------------------------------------------
@property NSString				*collectionName;
@property NSString				*collectionDescription;
@property NSMutableArray		*collection;				// array of Asset

@property NSDictionary          *defaultAssetLocation;

// ------------------------------------------------------------
// Asset access methods:
// ------------------------------------------------------------
- (NSURL*)assetURLAtIndex:(NSUInteger)index;
- (NSUInteger)assetIndexForURL:(NSURL*)url;
- (NSUInteger)assetIndexForLocation:(NSDictionary*)locationInfo;

// ------------------------------------------------------------
// Adding asset:
// ------------------------------------------------------------
- (NSUInteger)addAssetAtURL:(NSURL*)url
                    content:(BOOL)load
                   metadata:(NSDictionary*)metadataset
                dataOptions:(NSDictionary*)options;
- (NSUInteger)addAssetAtLocation:(NSDictionary*)locationInfo
                         content:(BOOL)load
                        metadata:(NSDictionary*)metadataset
                     dataOptions:(NSDictionary*)options;

// ------------------------------------------------------------
// Removing asset:
// ------------------------------------------------------------
- (void)removeAssetAtIndex:(NSUInteger)index;
- (void)removeAsset:(Asset*)asset;

// ------------------------------------------------------------
// Add a URL either as an asset or a role:
// ------------------------------------------------------------
- (NSUInteger)addURL:(NSURL*)url content:(BOOL)load metadata:(NSDictionary*)metadataset dataOptions:(NSDictionary*)dataOptions;

// ------------------------------------------------------------
//
// SCRIPTING BOOKKEEPING:
//
// ------------------------------------------------------------

// ------------------------------------------------------------
// Properties for the container and containerProperty fields:
// ------------------------------------------------------------
@property (readonly) id container;
@property (readonly) NSString *containerProperty;

// ------------------------------------------------------------
// Since the container and containerProperty fields are always
// set at the same time, we have lumped those setter calls
// together into one call that sets both:
// ------------------------------------------------------------
- (void)setContainer:(id)value andProperty:(NSString *)property;

// ------------------------------------------------------------
// kvc Cocoa property for the 'id' AppleScript property:
// ------------------------------------------------------------
@property (copy) NSString *uniqueID;

// ------------------------------------------------------------
// kvc Cocoa property for the 'name' AppleScript property:
// ------------------------------------------------------------
@property (copy) NSString *name;

// ------------------------------------------------------------
// kvc methods for the 'assets' AppleScript element.  Here we
// implement the methods necessary for maintaining the list of
// assets inside of a Document.  Note the names.
//
// In our scripting definition file we specified that the
// 'document' class contains an element of type 'asset',
// like so:
//
// <element type="asset"/>
//
// Cocoa will use the plural form of the class name, 'assets',
// when naming the property used by AppleScript to access the
// list of buckets, and we should use the property name when
// naming our methods.  So, using the property name, we
// name our methods as follows:
//
//  - (NSArray*) assets; (implied by property declaration)
//  -(void) insertInAssets:(id) asset;
//  -(void) insertInAssets:(id) asset atIndex:(unsigned)index;
//  -(void) removeFromAssetsAtIndex:(unsigned)index;
// ------------------------------------------------------------
 
// ------------------------------------------------------------
// Return the entire list of assets:
// ------------------------------------------------------------
@property (nonatomic, readonly) NSArray *assets;

// ------------------------------------------------------------
// Insert a asset at the beginning of the list:
// ------------------------------------------------------------
-(void) insertInAssets:(id) asset;

// ------------------------------------------------------------
// Insert a asset at some position in the list:
// ------------------------------------------------------------
-(void) insertInAssets:(id) asset atIndex:(unsigned)index;

// ------------------------------------------------------------
// Remove a asset from the list:
// ------------------------------------------------------------
-(void) removeFromAssetsAtIndex:(unsigned)index;

@end
