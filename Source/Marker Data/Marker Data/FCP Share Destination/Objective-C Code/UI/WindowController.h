//
//  WindowController.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#pragma once

#import <Cocoa/Cocoa.h>

@class Asset;

@interface WindowController : NSWindowController

- (instancetype)init;
- (instancetype)initWithWindow:(NSWindow *)window;

// ------------------------------------------------------------
// Update UI elements:
// ------------------------------------------------------------
- (void)clearDetailFields;
- (void)setDetailFieldsWithName:(NSString*)name mediaURL:(NSURL*)mediaURL descURL:(NSURL*)descURL;

- (void)updateSelectionDetailFields;
- (void)updateOutlineView:(id)sendor;

// ------------------------------------------------------------
// Add new asset without the contents:
// ------------------------------------------------------------
- (IBAction)newAsset:sender;
- (IBAction)finishNewAssetSheet:sender;
- (IBAction)cancelNewAssetSheet:sender;

// ------------------------------------------------------------
// Invoke the new asset UI:
// ------------------------------------------------------------
- (void)newAssetWithName:(NSString*)assetName
                metadata:(NSDictionary*)assetMetadata
             dataOptions:(NSDictionary*)assetDataOptions
       completionHandler:(void (^)(Asset* newAsset))handler;

@property (readwrite) BOOL   newAssetWantsDescription;
- (IBAction)updateNewAssetWantsDescription:(id)sender;

@end
