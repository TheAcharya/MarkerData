//
//  Document.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import <AppKit/NSApplication.h>

#import "Asset.h"
#import "Document.h"

#import "FCPXMetadataKeys.h"
#import "MediaAssetHelperKeys.h"

// ------------------------------------------------------------
// Document:
// ------------------------------------------------------------
@implementation Document
{
    // ------------------------------------------------------------
    //
	// PROPERTIES OF THE COLLECTION:
    //
    // ------------------------------------------------------------
    
    // ------------------------------------------------------------
    // Array of Asset:
    // ------------------------------------------------------------
	NSMutableArray *collection;
    
    // ------------------------------------------------------------
    // Asset URL to index:
    // ------------------------------------------------------------
	NSMutableDictionary *URLHash;
    
    // ------------------------------------------------------------
    // Asset UniqueID to index:
    // ------------------------------------------------------------
    NSMutableDictionary *UniqueIDHash;

    // ------------------------------------------------------------
    //
	// SCRIPTING BOOKKEEPING:
    //
    // ------------------------------------------------------------
    
    // ------------------------------------------------------------
    // Reference to the object containing this object:
    // ------------------------------------------------------------
	id container;
    
    // ------------------------------------------------------------
    // Name of the cocoa key on container specifying the list
    // property where this object is stored:
    // ------------------------------------------------------------
	NSString* containerProperty;
	
    // ------------------------------------------------------------
	// Storage for our id and name AppleScript properties.
    //
    // A unique id value for this object:
    // ------------------------------------------------------------
	NSString* uniqueID;
	
    // ------------------------------------------------------------
    // Default location for new asset:
    // ------------------------------------------------------------
    NSDictionary* defaultAssetLocation;
}

// ------------------------------------------------------------
// Initialize:
// ------------------------------------------------------------
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"[ShareDestinationKit] INFO - Create a new Collection Array...");
              
        // ------------------------------------------------------------
		// Create the collection array:
        // ------------------------------------------------------------
        collection      = [NSMutableArray arrayWithCapacity:0];
        URLHash         = [NSMutableDictionary dictionaryWithCapacity:0];
        UniqueIDHash    = [NSMutableDictionary dictionaryWithCapacity:0];
		collectionName  = [self displayName];
		uniqueID        = [Object calculateNewUniqueID];
        
        NSLog(@"[ShareDestinationKit] INFO - collectionName: %@", collectionName);
        NSLog(@"[ShareDestinationKit] INFO - uniqueID: %@", uniqueID);
        
    }
    return self;
}

// ------------------------------------------------------------
// Initialize with Contents of URL:
// ------------------------------------------------------------
- (instancetype)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError
{
    self = [super initWithContentsOfURL:url ofType:typeName error:outError];
	if (self) {
        
        NSLog(@"[ShareDestinationKit] INFO - Create a new Collection Array...");
        
        // ------------------------------------------------------------
		// Create the collection array:
        // ------------------------------------------------------------
        collection      = [NSMutableArray arrayWithCapacity:0];
        URLHash         = [NSMutableDictionary dictionaryWithCapacity:0];
        UniqueIDHash    = [NSMutableDictionary dictionaryWithCapacity:0];
		collectionName  = [[url URLByDeletingPathExtension] lastPathComponent];
		uniqueID        = [Object calculateNewUniqueID];
	}
	return self;
}

@synthesize collectionName;
@synthesize collectionDescription;
@synthesize collection;

@synthesize defaultAssetLocation;

#pragma mark Scripting Support Methods

// ------------------------------------------------------------
// Standard setter and getter methods for the container and
// containerProperty slots. The only thing that's unusual here
// is that we have lumped the setter functions together
// because we will always call them together:
// ------------------------------------------------------------
- (id)container {
    NSLog(@"[ShareDestinationKit] INFO - of %@ as %@", self.uniqueID, container);
    return container;
}

// ------------------------------------------------------------
// Container Property:
// ------------------------------------------------------------
- (NSString *)containerProperty {
    NSLog(@"[ShareDestinationKit] INFO - return  %@ as '%@'", self.uniqueID, containerProperty);
    return containerProperty;
}

// ------------------------------------------------------------
// Set Container:
// ------------------------------------------------------------
- (void)setContainer:(id)value andProperty:(NSString *)property {
    NSLog(@"[ShareDestinationKit] INFO - of %@ to %@ and '%@'", self.uniqueID, [value class], property);
    if (container != value) {
		container = value;
    }
    if (containerProperty != property) {
        containerProperty = [property copy];
    }
}

// ------------------------------------------------------------
// Standard setter and getter methods for the 'uniqueID'
// property nothing out of the ordinary here:
// ------------------------------------------------------------
- (NSString *)uniqueID {
    return uniqueID;
}

// ------------------------------------------------------------
// Set Unique ID:
// ------------------------------------------------------------
- (void)setUniqueID:(NSString *)value {
    NSLog(@"[ShareDestinationKit] INFO - of %@ to '%@'", self.uniqueID, value);
    if (uniqueID != value) {
        uniqueID = [value copy];
    }
}

// ------------------------------------------------------------
// Standard setter and getter methods for the 'name' property
// nothing out of the ordinary here:
// ------------------------------------------------------------
- (NSString *)name {
    NSLog(@"[ShareDestinationKit] INFO - of %@ as '%@'", self.uniqueID, self.collectionName);
    return self.collectionName;
}

// ------------------------------------------------------------
// Set Name:
// ------------------------------------------------------------
- (void)setName:(NSString *)value {
    NSLog(@"[ShareDestinationKit] INFO - of %@ to '%@'", self.uniqueID, value);
    if (self.collectionName != value) {
        self.collectionName = [value copy];
    }
}

#pragma mark Asset Access Methods

// ------------------------------------------------------------
// Asset URL at Index:
// ------------------------------------------------------------
- (NSURL*)assetURLAtIndex:(NSUInteger)index
{
	Asset *asset = (Asset*)[self.collection objectAtIndex:index];
    if ( asset == nil ) {
        return nil;
    } else {
        return [asset principalURL];
    }
}

// ------------------------------------------------------------
// Asset Index for URL:
// ------------------------------------------------------------
- (NSUInteger)assetIndexForURL:(NSURL*)url
{
    NSNumber *indexObject = [URLHash objectForKey:url];
    if ( indexObject != NULL ) {
        return [indexObject integerValue];
    } else {
        return -1;
    }
}

// ------------------------------------------------------------
// Asset Index for Unique ID:
// ------------------------------------------------------------
- (NSUInteger)assetIndexForUniqueID:(NSString*)theID
{
    NSNumber *indexObject = [UniqueIDHash objectForKey:theID];
    if ( indexObject != NULL ) {
        return [indexObject integerValue];
    } else {
        return -1;
    }
}

// ------------------------------------------------------------
// Asset Index for Location:
// ------------------------------------------------------------
- (NSUInteger)assetIndexForLocation:(NSDictionary*)locationInfo;
{
    NSURL       *folderURL = [locationInfo objectForKey:kMediaAssetLocationFolderKey];
    NSString    *baseName = [locationInfo objectForKey:kMediaAssetLocationBasenameKey];

    if ( folderURL == nil || baseName == nil ) {
        return -1;
    }
    
    NSURL *principalURL = [folderURL URLByAppendingPathComponent:baseName];
    
    return [self assetIndexForURL:principalURL];
}

// ------------------------------------------------------------
// Add Asset At Location:
// ------------------------------------------------------------
- (NSUInteger)addAssetAtLocation:(NSDictionary*)locationInfo
                         content:(BOOL)load
                        metadata:(NSDictionary*)metadataset
                     dataOptions:(NSDictionary*)options;
{
    
    NSLog(@"[ShareDestinationKit] INFO - addAssetAtLocation triggered!");
    
    NSLog(@"[ShareDestinationKit] INFO - locationInfo: %@", locationInfo);
    NSLog(@"[ShareDestinationKit] INFO - content: %d", load == 1);
    NSLog(@"[ShareDestinationKit] INFO - metadataset: %@", metadataset);
    NSLog(@"[ShareDestinationKit] INFO - options: %@", options);
    
    Asset       *theAsset           = nil;
    NSUInteger  assetIndex          = [self assetIndexForLocation:locationInfo];
    NSNumber    *hasMediaObject     = [locationInfo objectForKey:kMediaAssetLocationHasMediaKey];
    NSNumber    *hasDescObject      = [locationInfo objectForKey:kMediaAssetLocationHasDescriptionKey];
    BOOL        hasMedia            = hasMediaObject != nil && [hasMediaObject boolValue];
    BOOL        hasDesc             = hasDescObject != nil && [hasDescObject boolValue];
    NSString*   mediaExtension      = nil;
    NSString*   descExtension       = nil;

    if ( mediaExtension == nil && hasMedia ) {
        NSLog(@"[ShareDestinationKit] INFO - no media extension, but has media.");
        mediaExtension = @"mov";
    }
    
    if ( descExtension == nil && hasDesc ) {
        NSLog(@"[ShareDestinationKit] INFO - no description extension, but has description.");
        descExtension = @"fcpxml";
    }
    
    if ( assetIndex == -1 ) {
        
        NSLog(@"[ShareDestinationKit] INFO - no exciting assets");
        
        assetIndex = [self.assets count];
        
        NSLog(@"[ShareDestinationKit] INFO - assetIndex: %lu", (unsigned long)assetIndex);
        
        theAsset = [[Asset alloc] init:[locationInfo objectForKey:kMediaAssetLocationBasenameKey]
                                       at:[locationInfo objectForKey:kMediaAssetLocationFolderKey]
                                    media:mediaExtension
                                     desc:descExtension];
        
        NSLog(@"[ShareDestinationKit] INFO - theAsset: %@", theAsset);
        
        [theAsset setMetadata:metadataset];
        [theAsset addMetadata:@"1" forKey:kMetadataKeyManagedAsset];
        [theAsset setDataOptions:options];
        
        [self insertInAssets:theAsset atIndex:(unsigned int)assetIndex];
        
    } else {
        
        NSLog(@"[ShareDestinationKit] INFO - there are exciting assets");
        
        theAsset = [self.assets objectAtIndex:assetIndex];
        
        if ( mediaExtension != nil ) {
            // ------------------------------------------------------------
            // Has a Media Extension:
            // ------------------------------------------------------------
            [theAsset setMediaExtension:mediaExtension];
        } else if ( hasMediaObject != nil && ! hasMedia ) {
            // ------------------------------------------------------------
            // Remove the extension if that was an explicit NO:
            // ------------------------------------------------------------
            [theAsset setMediaExtension:nil];
        }
        
        if ( descExtension != nil ) {
            // ------------------------------------------------------------
            // Has a Description Extension:
            // ------------------------------------------------------------
            [theAsset setDescExtension:descExtension];
        } else if ( hasDescObject != nil && ! hasDesc ) {
            // ------------------------------------------------------------
            // Remove the extension if that was an explicit NO:
            // ------------------------------------------------------------
            [theAsset setDescExtension:nil];
        }
        
        for ( NSString* key in metadataset ) {
            [theAsset addMetadata:[metadataset objectForKey:key] forKey:key];
        }
        for ( NSString* key in options ) {
            [theAsset setDataOption:[options objectForKey:key] forKey:key];
        }
    }
    
    if ( load ) {
        if ( hasMedia  ) {
            [theAsset loadMedia];
        }
        
        if ( hasDesc ) {
            [theAsset loadDescription];
        }
    }
    
    return assetIndex;
}

// ------------------------------------------------------------
// Add Asset at URL:
// ------------------------------------------------------------
- (NSUInteger)addAssetAtURL:(NSURL*)url content:(BOOL)load metadata:(NSDictionary*)metadataset dataOptions:(NSDictionary*)options
{
    NSLog(@"[ShareDestinationKit] INFO - addAssetAtURL triggered!");
    
    NSURL           *principalURL   = [url URLByDeletingPathExtension];
    NSURL           *folderURL      = [principalURL URLByDeletingLastPathComponent];
    NSString        *baseName       = [principalURL lastPathComponent];
    NSString        *extension      = [url pathExtension];
    NSDictionary    *locationInfo   = nil;

    if ( [Asset isMediaExtension:extension] ) {
        locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:folderURL, kMediaAssetLocationFolderKey,
                        baseName, kMediaAssetLocationBasenameKey,
                        [NSNumber numberWithBool:YES], kMediaAssetLocationHasMediaKey,
                        nil];
    }
    else if ( [Asset isDescExtension:extension] ) {
        locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:folderURL, kMediaAssetLocationFolderKey,
                        baseName, kMediaAssetLocationBasenameKey,
                        [NSNumber numberWithBool:YES], kMediaAssetLocationHasDescriptionKey,
                        nil];
    }
    else {
        // ------------------------------------------------------------
        // Register with basename only:
        // ------------------------------------------------------------
        locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:folderURL, kMediaAssetLocationFolderKey, baseName, kMediaAssetLocationBasenameKey, nil];
    }
    
    return [self addAssetAtLocation:locationInfo content:load metadata:metadataset dataOptions:options];
}

// ------------------------------------------------------------
// Remove Asset At Index:
// ------------------------------------------------------------
- (void)removeAssetAtIndex:(NSUInteger)index
{
    NSLog(@"[ShareDestinationKit] INFO - removeAssetAtIndex: %lu", (unsigned long)index);
	[self removeFromAssetsAtIndex:(unsigned int)index];
}

// ------------------------------------------------------------
// Remove Asset:
// ------------------------------------------------------------
- (void)removeAsset:(Asset*)asset
{
    NSLog(@"[ShareDestinationKit] INFO - removeAsset: %@", asset);
    [URLHash removeObjectForKey:[asset principalURL]];
    [UniqueIDHash removeObjectForKey:asset.uniqueID];
    [self.collection removeObject:asset];
}

// ------------------------------------------------------------
// Add URL:
// ------------------------------------------------------------
- (NSUInteger)addURL:(NSURL*)url
             content:(BOOL)load
            metadata:(NSDictionary*)metadataset
         dataOptions:(NSDictionary*)dataOptions
{
    NSLog(@"[ShareDestinationKit] INFO - addURL: %@", url);
    
    NSURL*      principalURL = nil;
    NSUInteger  assetIndex = -1;
    
    if ( principalURL == nil ) {
        // ------------------------------------------------------------
        // If the URL does not represent a role file then add the URL
        // as a standalone non-role asset:
        // ------------------------------------------------------------
        assetIndex = [self addAssetAtURL:url content:load metadata:metadataset dataOptions:dataOptions];
    }

    return assetIndex;
}

#pragma mark KVC Asset Accessors

// ------------------------------------------------------------
// kvc methods for the 'assets' AppleScript element.
//
// Here we implement the methods necessary for maintaining the
// list of assets inside of a Bucket. Note the names.
// In our scripting definition file we specified that the 
// 'bucket' class contains an element of type 'asset', like so:
//
//  <element type="asset"/>
//
// Cocoa will use the plural form of the class name, 'assets',
// when naming the property used by AppleScript to access the
// list of buckets, and we should use the property name when
// naming our methods.  So, using the property name, we name
// our methods as follows:
//
//  - (NSArray*) assets;
//  -(void) insertInAssets:(id) asset;
//  -(void) insertInAssets:(id) asset atIndex:(unsigned)index;
//  -(void) removeFromAssetsAtIndex:(unsigned)index;
// ------------------------------------------------------------

// ------------------------------------------------------------
// Return the entire list of assets:
// ------------------------------------------------------------
- (NSArray*) assets {
    NSLog(@"[ShareDestinationKit] INFO - returning assets from a bucket %@", self.uniqueID);
	return self.collection;
}

// ------------------------------------------------------------
// Insert a asset at the beginning of the list:
// ------------------------------------------------------------
-(void) insertInAssets:(id) asset {
    Asset* assetObject = (Asset*)asset;
    NSNumber *indexObject = [NSNumber numberWithInteger:0];
    NSLog(@"[ShareDestinationKit] INFO - inserting asset %@ into bucket %@", assetObject.uniqueID, self.uniqueID);
	[asset setContainer:self andProperty:@"assets"];
	[self.collection insertObject:assetObject atIndex:0];
    [URLHash setObject:indexObject forKey:[assetObject principalURL]];
    [UniqueIDHash setObject:indexObject forKey:assetObject.uniqueID];
}

// ------------------------------------------------------------
// Insert an asset at some position in the list:
// ------------------------------------------------------------
-(void) insertInAssets:(id) asset atIndex:(unsigned)index {
    Asset* assetObject      = (Asset*)asset;
    NSNumber *indexObject   = [NSNumber numberWithInteger:index];
    
    NSLog(@"[ShareDestinationKit] INFO - insert asset %@ at index %d into bucket %@", assetObject.uniqueID, index, self.uniqueID);
    
	[asset setContainer:self andProperty:@"assets"];
	[self.collection insertObject:assetObject atIndex:index];
    [URLHash setObject:indexObject forKey:[assetObject principalURL]];
    [UniqueIDHash setObject:indexObject forKey:assetObject.uniqueID];
}

// ------------------------------------------------------------
// Remove a asset from the list:
// ------------------------------------------------------------
-(void) removeFromAssetsAtIndex:(unsigned)index {
    NSLog(@"[ShareDestinationKit] INFO - removing asset at %d from bucket %@", index, self.uniqueID);
    Asset* assetObject = [self.collection objectAtIndex:index];
    [URLHash removeObjectForKey:[assetObject principalURL]];
    [UniqueIDHash removeObjectForKey:assetObject.uniqueID];
    [self.collection removeObjectAtIndex:index];
}

// ------------------------------------------------------------
// Resolve an object specifier into an asset index:
// ------------------------------------------------------------
- (NSArray *)indicesOfObjectsByEvaluatingObjectSpecifier:(NSScriptObjectSpecifier *)specifier
{
    if ([specifier isKindOfClass:[NSUniqueIDSpecifier class]]) {
        NSUniqueIDSpecifier     *theSpecifier = (NSUniqueIDSpecifier*)specifier;
        NSString    *theID = [theSpecifier uniqueID];
        NSInteger   index = [self assetIndexForUniqueID:theID];
        
        if ( index == -1 ) {
            return [NSArray array];
        }
        else {
            return [NSArray arrayWithObject:[NSNumber numberWithInteger:index]];
        }
    }
    else
        return nil;
}

#pragma mark Serialization / Deserialization

// ------------------------------------------------------------
// Autosaves In Place:
// ------------------------------------------------------------
+ (BOOL)autosavesInPlace
{
    return YES;
}

// ------------------------------------------------------------
// Data Of Type:
// ------------------------------------------------------------
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	NSData *dataToWrite = nil;
	
	if ( [typeName isEqualToString:@"Asset Collection"]) {
		NSMutableArray *urlStrings = [NSMutableArray arrayWithCapacity:0];
		
		for ( Asset *asset in self.collection ) {
			NSString *string = [[asset mediaFile] absoluteString];

			[urlStrings addObject:string];
		}
		
		dataToWrite = [[urlStrings componentsJoinedByString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
	}
	else {
        if ( outError != NULL ) {
            *outError = [NSError errorWithDomain:@"ShareDestinationKit" code:304 userInfo:nil];
        }
	}
	
	return dataToWrite;
}

// ------------------------------------------------------------
// Read From Data:
// ------------------------------------------------------------
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	if ( [typeName isEqualToString:@"Asset Collection"]) {

		NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSArray *urlStrings = [dataString componentsSeparatedByString:@"\n"];
		
        // ------------------------------------------------------------
		// Empty the content of the document:
        // ------------------------------------------------------------
		[self.collection removeAllObjects];
		
        // ------------------------------------------------------------
		// Populate the new content:
        // ------------------------------------------------------------
		for ( NSString *urlString in urlStrings ) {
			NSURL *url = [NSURL URLWithString:urlString];
			Asset *newAsset = [[Asset alloc] init:url];
			
			[self insertInAssets:newAsset atIndex:(unsigned int)[self.assets count]];
		}
		return YES;
	}
	else {
		if ( outError != NULL )
			*outError = [NSError errorWithDomain:@"ShareDestinationKit" code:204 userInfo:nil];

		return NO;
	}
}

#pragma mark Load & Save Data Methods

// ------------------------------------------------------------
// Standard NSDocument load and save data methods:
//
// These methods create an archive of the collection and
// unarchive an existing archive to reconstitute the collection.
//
// For more details, see:
//  - NSDocument Class Reference
//  - Document-Based Applications Overview
// ------------------------------------------------------------
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (NSData *)dataRepresentationOfType:(NSString *)aType
#pragma GCC diagnostic pop
{
    // ------------------------------------------------------------
	// Create an archive of the collection and its attributes:
    // ------------------------------------------------------------
    NSKeyedArchiver *archiver;
    NSMutableData *data = [NSMutableData data];
	
    archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
    [archiver encodeObject:self.collectionName forKey:@"name"];
    [archiver encodeObject:self.collectionDescription forKey:@"collectionDescription"];
    [archiver encodeObject:self.collection forKey:@"collection"];
	
    [archiver finishEncoding];
	
    return data;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
#pragma GCC diagnostic pop
{
    NSKeyedUnarchiver *unarchiver;
	
    // ------------------------------------------------------------
	// Extract an archive of the collection and its attributes:
    // ------------------------------------------------------------
    unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	
    self.collectionName = [unarchiver decodeObjectForKey:@"name"];
    self.collectionDescription = [unarchiver decodeObjectForKey:@"collectionDescription"];
    self.collection = [unarchiver decodeObjectForKey:@"collection"];
	
    [unarchiver finishDecoding];
	
    return YES;
}

@end
