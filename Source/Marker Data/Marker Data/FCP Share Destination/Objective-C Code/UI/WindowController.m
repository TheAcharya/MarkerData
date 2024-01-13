//
//  WindowController.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

@import UniformTypeIdentifiers;

#import "WindowController.h"

#import "Asset.h"
#import "Document.h"

#import "MediaAssetHelperKeys.h"
#import "FCPXMetadataKeys.h"

@interface WindowController ()

// ------------------------------------------------------------
// User Interface elements on the document window:
// ------------------------------------------------------------
@property (weak) IBOutlet NSOutlineView  *outlineView;

@property (weak) IBOutlet NSTextField    *selectedAssetTitleField;
@property (weak) IBOutlet NSTextField    *selectedAssetMediaURLField;
@property (weak) IBOutlet NSTextField    *selectedAssetDescURLField;

// ------------------------------------------------------------
// The new asset sheet:
// ------------------------------------------------------------
@property IBOutlet NSWindow              *sheetForNewAsset;
@property (weak) IBOutlet NSTextField    *nameFieldForNewAsset;
@property (weak) IBOutlet NSPopUpButton  *locationTypePopupForNewAsset;
@property (weak) IBOutlet NSTextField    *locationFolderURLFieldForNewAsset;

// ------------------------------------------------------------
// Metadata pane:
// ------------------------------------------------------------
@property (weak) IBOutlet NSTextField    *descriptionFieldForNewAsset;
@property (weak) IBOutlet NSDatePicker   *expirationDatePickerForNewAsset;
@property (weak) IBOutlet NSTextField    *shareIDFieldForNewAsset;
@property (weak) IBOutlet NSTextField    *episodeIDFieldForNewAsset;
@property (weak) IBOutlet NSTextField    *episodeNumberFieldForNewAsset;

// ------------------------------------------------------------
// Data Options Pane:
// ------------------------------------------------------------
@property (weak) IBOutlet NSPopUpButton  *metadataSetPopupForNewAsset;
@property (weak) IBOutlet NSButton       *hasDescriptionCheckBoxForNewAsset;

@end

// ------------------------------------------------------------
// Window Controller:
// ------------------------------------------------------------
@implementation WindowController
{
    BOOL askUserNewAssetPath;
    BOOL newAssetWantsDescription;
}

// ------------------------------------------------------------
// Initialize:
// ------------------------------------------------------------
- (instancetype)init
{
    self = [super initWithWindowNibName:@"Document"];
    if (self) {
        // ------------------------------------------------------------
		// Add more initialization if required here:
        // ------------------------------------------------------------
    }
    return self;
}

// ------------------------------------------------------------
// Initialize with Window:
// ------------------------------------------------------------
- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // ------------------------------------------------------------
		// Add more initialization if required here:
        // ------------------------------------------------------------
    }
    return self;
}

// ------------------------------------------------------------
// Update user interface on load:
// ------------------------------------------------------------
- (void)windowDidLoad
{
    NSLog(@"[ShareDestinationKit] INFO - windowDidLoad triggered");
    [self updateSelectionDetailFields];
}

#pragma mark Managing Text Fields

// ------------------------------------------------------------
// Update the outline view:
// ------------------------------------------------------------
- (void)updateOutlineView:(id)sender
{
    NSLog(@"[ShareDestinationKit] INFO - updateOutlineView triggered");
    [self.outlineView reloadData];
    [self.outlineView deselectAll:sender];
}

// ------------------------------------------------------------
// Update the text fields that display details about the
// selected item:
// ------------------------------------------------------------
- (void)clearDetailFields
{
    NSLog(@"[ShareDestinationKit] INFO - clearDetailFields triggered");
    [self.selectedAssetTitleField setStringValue:@"No selection"];
    [self.selectedAssetTitleField setSelectable:NO];
    [self.selectedAssetMediaURLField setStringValue:@"No selection"];
    [self.selectedAssetMediaURLField setSelectable:NO];
    [self.selectedAssetDescURLField setStringValue:@"No selection"];
    [self.selectedAssetDescURLField setSelectable:NO];
}

// ------------------------------------------------------------
// Set Detail Fields With Name:
// ------------------------------------------------------------
- (void)setDetailFieldsWithName:(NSString*)name mediaURL:(NSURL*)mediaURL descURL:(NSURL*)descURL
{
    NSLog(@"[ShareDestinationKit] INFO - setDetailFieldsWithName triggered");
    NSString* URLString = nil;
    
    [self.selectedAssetTitleField setStringValue:name];
    [self.selectedAssetTitleField setEditable:YES];
    
    if ( mediaURL != nil ) {
        URLString = [mediaURL absoluteString];
    }
    else {
        URLString = @"No URL";
    }
    [self.selectedAssetMediaURLField setStringValue:URLString];
    [self.selectedAssetMediaURLField setEditable:YES];
    
    if ( descURL != nil ) {
        URLString = [descURL absoluteString];
    }
    else {
        URLString = @"No URL";
    }
    [self.selectedAssetDescURLField setStringValue:URLString];
    [self.selectedAssetDescURLField setEditable:YES];
}

// ------------------------------------------------------------
// Update Selection Detail Fields:
// ------------------------------------------------------------
- (void)updateSelectionDetailFields
{
    NSLog(@"[ShareDestinationKit] INFO - updateSelectionDetailFields triggered");
	NSInteger selectedRow = [self.outlineView selectedRow];
    
    NSLog(@"[ShareDestinationKit] INFO - selectedRow: %ld", (long)selectedRow);
    
	if (selectedRow == -1) {
        [self clearDetailFields];
	} else {
		id selectedItem = [self.outlineView itemAtRow:selectedRow]; // [self.assets objectAtIndex:selectedRow];
        if ( selectedItem != nil ) {
            if ( [selectedItem isMemberOfClass:[Asset class]] ) {
                Asset* selectedAsset = (Asset*)selectedItem;
                
                [self setDetailFieldsWithName:[selectedAsset name] mediaURL:[selectedAsset mediaFile] descURL:[selectedAsset descFile]];
            }
        }
	}
}

#pragma mark New Asset

// ------------------------------------------------------------
// New Asset:
// ------------------------------------------------------------
- (IBAction)newAsset:sender
{
    NSLog(@"[ShareDestinationKit] INFO - newAsset triggered");
    [self newAssetWithName:nil
                  metadata:nil
               dataOptions:nil
         completionHandler:^(Asset *newAsset) {
             if ( newAsset != nil ) {
                 
                 // ------------------------------------------------------------
                 // Update the user interface:
                 // ------------------------------------------------------------
                 NSLog(@"[ShareDestinationKit] INFO - Update the user interface with a new nil asset: %@", newAsset);
                 [self updateOutlineView:nil];
                 [self updateSelectionDetailFields];
             }
         }];
}

// ------------------------------------------------------------
// New Asset With Name:
// ------------------------------------------------------------
- (void)newAssetWithName:(NSString*)assetName
                metadata:(NSDictionary*)assetMetadata
             dataOptions:(NSDictionary*)assetDataOptions
       completionHandler:(void (^)(Asset* newAsset))handler
{
    NSLog(@"[ShareDestinationKit] INFO - newAssetWithName triggered");
    
    NSLog(@"[ShareDestinationKit] INFO - assetName: %@", assetName);
    NSLog(@"[ShareDestinationKit] INFO - assetMetadata: %@", assetMetadata);
    NSLog(@"[ShareDestinationKit] INFO - assetDataOptions: %@", assetDataOptions);
          
    // ------------------------------------------------------------
    // if assetName is empty, default to "Untitled":
    // ------------------------------------------------------------
    if ( assetName == nil ) {
        NSLog(@"[ShareDestinationKit] INFO - assetName is empty, default to 'Untitled'");
        assetName = @"Untitled";
    }
    
    // ------------------------------------------------------------
    // Bring up the custom sheet:
    // ------------------------------------------------------------
    [self invokeNewAssetSheetNamed:assetName
                          metadata:assetMetadata
                       dataOptions:assetDataOptions
                          delegate:self
                    didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
                       contextInfo:(void*)CFBridgingRetain(handler)];
}


#pragma mark New Asset Sheet

// ------------------------------------------------------------
// Invoke New Asset Sheet Named:
// ------------------------------------------------------------
- (void)invokeNewAssetSheetNamed:(NSString*)assetName
                        metadata:(NSDictionary*)assetMetadata
                     dataOptions:(NSDictionary*)assetDataOptions
                        delegate:(id)modalDelegate
                  didEndSelector:(SEL)didEndSelector contextInfo:(void*)contextInfo
{
    
    NSLog(@"[ShareDestinationKit] INFO - invokeNewAssetSheetNamed triggered");
    
    Document* document = [self document];

    if ( !self.sheetForNewAsset ) {
		[[NSBundle mainBundle] loadNibNamed:@"NewAssetSheet" owner:self topLevelObjects:NULL];
	}
	
	[self.nameFieldForNewAsset setStringValue:assetName];
    [self populateAssetLocation:document.defaultAssetLocation];
    [self populateNewAssetMetadata:assetMetadata];
    [self populateNewAssetDataOptions:assetDataOptions];
    [self selectNewAssetFolder:nil];
    [self updateNewAssetWantsDescription:nil];
    
	NSWindow* docWindow = [self window];
        
    [docWindow beginSheet:self.sheetForNewAsset completionHandler:^(NSModalResponse returnCode) {
        if (modalDelegate && [modalDelegate respondsToSelector:didEndSelector]) {
            IMP imp = [modalDelegate methodForSelector:didEndSelector];
            void (*func)(id, SEL, NSWindow *, NSInteger, void *) = (void *)imp;
            func(modalDelegate, didEndSelector, self.sheetForNewAsset, returnCode, contextInfo);
        }
    }];

}

// ------------------------------------------------------------
// Finish New Asset Sheet:
// ------------------------------------------------------------
- (IBAction)finishNewAssetSheet:sender
{
    NSLog(@"[ShareDestinationKit] INFO - finishNewAssetSheet triggered");
    [NSApp endSheet:self.sheetForNewAsset returnCode:NSModalResponseOK];
}

// ------------------------------------------------------------
// Cancel New Asset Sheet:
// ------------------------------------------------------------
- (IBAction)cancelNewAssetSheet:sender
{
    NSLog(@"[ShareDestinationKit] INFO - cancelNewAssetSheet triggered");
    [NSApp endSheet:self.sheetForNewAsset returnCode:NSModalResponseCancel];
}

// ------------------------------------------------------------
// Did End Sheet:
// ------------------------------------------------------------
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"[ShareDestinationKit] INFO - didEndSheet triggered");
    
    Asset*       newAsset = nil;
    Document*    document = [self document];
    
    NSLog(@"[ShareDestinationKit] INFO - document: %@", document);
    
	if ( returnCode == NSModalResponseOK ) {
        
        NSLog(@"[ShareDestinationKit] INFO - returnCode is NSModalResponseOK!");
        
        NSDictionary    *newAssetLocationInfo = [self collectAssetLocation];
        
        NSLog(@"[ShareDestinationKit] INFO - newAssetLocationInfo: %@", newAssetLocationInfo);
        
        NSUInteger      assetIndex = [document addAssetAtLocation:newAssetLocationInfo
                                                          content:NO
                                                         metadata:[self collectNewAssetMetadata]
                                                      dataOptions:[self collectNewAssetDataOptions]];
        
        NSLog(@"[ShareDestinationKit] INFO - assetIndex: %lu", (unsigned long)assetIndex);
        
        document.defaultAssetLocation = newAssetLocationInfo;
        newAsset = [document.assets objectAtIndex:assetIndex];
        
        NSLog(@"[ShareDestinationKit] INFO - newAsset: %@", newAsset);
	}
    [sheet orderOut:self];

    // ------------------------------------------------------------
    // Update the User Interface:
    // ------------------------------------------------------------
    NSLog(@"[ShareDestinationKit] INFO - Update the user interface...");
    [self updateOutlineView:nil];
    [self updateSelectionDetailFields];

    // ------------------------------------------------------------
    // Invoke the user completion handler:
    // ------------------------------------------------------------
    ((void(^)(Asset*))CFBridgingRelease(contextInfo))(newAsset);
}

// ------------------------------------------------------------
// Select New Asset Folder:
// ------------------------------------------------------------
- (IBAction)selectNewAssetFolder:sender
{
    NSLog(@"[ShareDestinationKit] INFO - selectNewAssetFolder triggered");
    
	NSInteger dirSelector = -1;
	
	switch ( [self.locationTypePopupForNewAsset indexOfSelectedItem] ) {
		case 0: dirSelector = NSMoviesDirectory; break;
		case 1: dirSelector = NSPicturesDirectory; break;
		case 2: dirSelector = NSDocumentDirectory; break;
		case 3: dirSelector = NSMusicDirectory; break;
	}
    
	if ( dirSelector == -1 ) {
        // ------------------------------------------------------------
        // Bring up the open panel when invoked from the user interface
        // otherwise leave the chosen location alone:
        // ------------------------------------------------------------
        if ( sender != nil ) {
            NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            
            [openPanel setAllowsMultipleSelection:NO];
            [openPanel setCanChooseDirectories:YES];
            [openPanel setCanChooseFiles:NO];
            [openPanel beginSheetModalForWindow:self.sheetForNewAsset completionHandler:^(NSInteger result) {
                NSURL* folderURL = [[openPanel URLs] objectAtIndex:0];
                [self.locationFolderURLFieldForNewAsset setStringValue:[folderURL absoluteString]];
            }];
        }
    }
    else {
        NSURL *folderURL = [[[NSFileManager defaultManager] URLForDirectory:dirSelector inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil] URLByResolvingSymlinksInPath];
        [self.locationFolderURLFieldForNewAsset setStringValue:[folderURL absoluteString]];
    }
}

// ------------------------------------------------------------
// Collect Asset Location:
// ------------------------------------------------------------
- (NSDictionary*)collectAssetLocation
{
    NSLog(@"[ShareDestinationKit] INFO - collectAssetLocation triggered");
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSURL URLWithString:[self.locationFolderURLFieldForNewAsset stringValue]], kMediaAssetLocationFolderKey,
            [self.nameFieldForNewAsset stringValue], kMediaAssetLocationBasenameKey,
            [NSNumber numberWithBool:YES], kMediaAssetLocationHasMediaKey,
            [NSNumber numberWithBool:self.newAssetWantsDescription], kMediaAssetLocationHasDescriptionKey,
            nil];
}

// ------------------------------------------------------------
// Populate Asset Location:
// ------------------------------------------------------------
- (void)populateAssetLocation:(NSDictionary*)locationInfo
{
    NSLog(@"[ShareDestinationKit] INFO - populateAssetLocation triggered");
    NSURL       *folderURL = [locationInfo objectForKey:kMediaAssetLocationFolderKey];
    NSNumber    *wantsDescription = [locationInfo objectForKey:kMediaAssetLocationHasDescriptionKey];
    
    if ( [self.locationTypePopupForNewAsset indexOfSelectedItem]  == -1 ) {
        [self.locationFolderURLFieldForNewAsset setStringValue:[folderURL absoluteString]];
    }
 
    if ( wantsDescription != NULL && [wantsDescription boolValue] ) {
        self.newAssetWantsDescription = YES;
    }
}

// ------------------------------------------------------------
// Collect New Asset Metadata:
// ------------------------------------------------------------
- (NSDictionary*)collectNewAssetMetadata
{
    NSLog(@"[ShareDestinationKit] INFO - collectNewAssetMetadata triggered");
	NSMutableDictionary* metadataset = [NSMutableDictionary dictionaryWithCapacity:0];
	
	[metadataset setObject:[self.descriptionFieldForNewAsset stringValue] forKey:kFCPXMetadataKeyDescription];
	[metadataset setObject:[self.expirationDatePickerForNewAsset dateValue] forKey:kMetadataKeyExpirationDate];
    [metadataset setObject:[self.shareIDFieldForNewAsset stringValue] forKey:kFCPXShareMetadataKeyShareID];
    [metadataset setObject:[self.episodeIDFieldForNewAsset stringValue] forKey:kFCPXShareMetadataKeyEpisodeID];
    [metadataset setObject:@([self.episodeNumberFieldForNewAsset integerValue]) forKey:kFCPXShareMetadataKeyEpisodeNumber];
	[metadataset setObject:@"1" forKey:kMetadataKeyPreparedAsset];
	
	return [NSDictionary dictionaryWithDictionary:metadataset];
}

// ------------------------------------------------------------
// Populate New Asset Metadata:
// ------------------------------------------------------------
- (void)populateNewAssetMetadata:(NSDictionary*)metadataset
{
    NSLog(@"[ShareDestinationKit] INFO - populateNewAssetMetadata triggered");
    
    // ------------------------------------------------------------
    // Description:
    // ------------------------------------------------------------
    NSString *description = [metadataset objectForKey:kFCPXMetadataKeyDescription];
    if ( description == nil ) {
        description = @"";
    }
    [self.descriptionFieldForNewAsset setStringValue:description];
    
    // ------------------------------------------------------------
    // Expiration Date:
    // ------------------------------------------------------------
    NSDate *expirationDate = [metadataset objectForKey:kMetadataKeyExpirationDate];
    if ( expirationDate == nil ) {
        expirationDate = [NSDate dateWithTimeIntervalSinceNow:0];
    }
    [self.expirationDatePickerForNewAsset setDateValue:expirationDate];
    
    // ------------------------------------------------------------
    // Share ID:
    // ------------------------------------------------------------
    NSString* shareID = [metadataset objectForKey:kFCPXShareMetadataKeyShareID];
    if ( shareID == nil ) {
        shareID = @"";
    }
    [self.shareIDFieldForNewAsset setStringValue:shareID];

    // ------------------------------------------------------------
    // Episode ID:
    // ------------------------------------------------------------
    NSString* episodeID = [metadataset objectForKey:kFCPXShareMetadataKeyEpisodeID];
    if ( episodeID == nil ) {
        episodeID = @"";
    }
    [self.episodeIDFieldForNewAsset setStringValue:episodeID];
    
    // ------------------------------------------------------------
    // Episode Number:
    // ------------------------------------------------------------
    NSString *episodeNumber = [metadataset objectForKey:kFCPXShareMetadataKeyEpisodeNumber];
    if ( episodeNumber == nil ) {
        episodeNumber = @"";
    }
    [self.episodeNumberFieldForNewAsset setStringValue:episodeNumber];
}

// ------------------------------------------------------------
// Data Options Pane:
// ------------------------------------------------------------
- (NSDictionary*)collectNewAssetDataOptions
{
    NSLog(@"[ShareDestinationKit] INFO - collectNewAssetDataOptions triggered");
    NSMutableDictionary*    dataOptions = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString* theMetadataSetName = [self.metadataSetPopupForNewAsset titleOfSelectedItem];
    if ( theMetadataSetName != nil ) {
        [dataOptions setObject:theMetadataSetName forKey:kMediaAssetDataOptionMetadataSetKey];
    }
    
    return [NSDictionary dictionaryWithDictionary:dataOptions];
}

// ------------------------------------------------------------
// Populate New Asset Data Options:
// ------------------------------------------------------------
- (void)populateNewAssetDataOptions:(NSDictionary*)dataOptions
{
    NSLog(@"[ShareDestinationKit] INFO - populateNewAssetDataOptions triggered");
    NSArray* availableMetadataSets = [dataOptions objectForKey:kMediaAssetDataOptionAvailableMetadataSetsKey];
    
    if ( availableMetadataSets != nil && [availableMetadataSets isKindOfClass:[NSArray class]] ) {
        [self.metadataSetPopupForNewAsset removeAllItems];
        [self.metadataSetPopupForNewAsset addItemWithTitle:@"None"];
        [self.metadataSetPopupForNewAsset addItemsWithTitles:availableMetadataSets];
    }
}

// ------------------------------------------------------------
// New Asset Wants Description:
// ------------------------------------------------------------
- (BOOL)newAssetWantsDescription
{
    return newAssetWantsDescription;
}

// ------------------------------------------------------------
// Set New Asset Wants Description:
// ------------------------------------------------------------
- (void)setNewAssetWantsDescription:(BOOL)newValue
{
    newAssetWantsDescription = newValue;
}

// ------------------------------------------------------------
// Update New Asset Wants Description:
// ------------------------------------------------------------
- (IBAction)updateNewAssetWantsDescription:(id)sender
{
    [self setNewAssetWantsDescription:[self.hasDescriptionCheckBoxForNewAsset state]];
}

#pragma mark Add/Remove Assets

// ------------------------------------------------------------
// Add a file as a new asset:
// ------------------------------------------------------------
- (IBAction)addAsset:sender
{
    NSLog(@"[ShareDestinationKit] INFO - addAsset triggered");
    
    Document* document = [self document];
    
    // ------------------------------------------------------------
	// Bring up a open panel:
    // ------------------------------------------------------------
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    /*
    if (@available(macOS 11.0, *)) {
        openPanel.allowedContentTypes = @[
            [UTType typeWithIdentifier:@"public.movie"], // Equivalent to AVFileTypeQuickTimeMovie
            [UTType typeWithIdentifier:@"public.mpeg-4"], // Equivalent to AVFileTypeMPEG4
            // Note: For 'AVFileTypeAppleM4V', use a general video UTI or a specific one if available
            [UTType typeWithIdentifier:@"public.m4v"], // Assuming 'public.m4v' for AVFileTypeAppleM4V
            [UTType typeWithIdentifier:@"public.aiff-audio"], // Equivalent to AVFileTypeAIFF
            [UTType typeWithIdentifier:@"public.wav"], // Equivalent to AVFileTypeWAVE
            // Note: For 'AVFileTypeAppleM4A', use a general audio UTI or a specific one if available
            [UTType typeWithIdentifier:@"public.m4a-audio"], // Assuming 'public.m4a-audio' for AVFileTypeAppleM4A
            [UTType typeWithIdentifier:@"public.aiff-audio"] // 'aiff' repeated
        ];
    } else {
        // Fallback for macOS versions prior to 11.0
        [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"mov", @"mp4", @"m4v", @"aiff", @"wav", @"m4a", @"aiff", nil]];
    }
    */
    
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:AVFileTypeQuickTimeMovie, AVFileTypeMPEG4, AVFileTypeAppleM4V, AVFileTypeAIFF, AVFileTypeWAVE, AVFileTypeAppleM4A, @"aiff", nil]];
    
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setMessage:@"Choose asset media file to add"];
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
		if (result == NSModalResponseOK) {
			NSArray *selectedURLs = [openPanel URLs];
			
			for ( NSURL* theURL in selectedURLs ) {
                // ------------------------------------------------------------
				// Create a new Asset and add it to the collection:
                // ------------------------------------------------------------
				[document addURL:theURL content:YES metadata:nil dataOptions:nil];
			}
			
            // ------------------------------------------------------------
			// Update the User Interface:
            // ------------------------------------------------------------
            [self updateOutlineView:sender];
			[self updateSelectionDetailFields];
		}
	}];
}

// ------------------------------------------------------------
// Remove Selected Assets:
// ------------------------------------------------------------
- (IBAction)removeSelectedAssets:sender
{
    NSLog(@"[ShareDestinationKit] INFO - removeSelectedAssets triggered");
    
    Document* document = [self document];
    
    // ------------------------------------------------------------
	// Find which Assets are selected and remove them:
    // ------------------------------------------------------------
	NSIndexSet *selectedRows = [self.outlineView selectedRowIndexes];
	NSInteger currentIndex = [selectedRows lastIndex];
    
    while (currentIndex != NSNotFound) {
        id selectedItem = [self.outlineView itemAtRow:currentIndex];
        
        if ( selectedItem == nil )
            continue;
        else if ( [selectedItem isMemberOfClass:[Asset class]] ) {
            Asset *asset = (Asset*)selectedItem;
            [document removeAsset:asset];
        }
        currentIndex = [selectedRows indexLessThanIndex: currentIndex];
    }
	
    // ------------------------------------------------------------
	// Update the user interface:
    // ------------------------------------------------------------
    [self updateOutlineView:sender];
	[self updateSelectionDetailFields];
}

@end
