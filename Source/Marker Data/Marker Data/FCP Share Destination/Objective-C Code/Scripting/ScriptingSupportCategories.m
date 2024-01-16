//
//  ScriptingSupportCategories.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

// ------------------------------------------------------------
//  Cocoa Scripting Support Categories:
//
//  This file contains four Objective-C Categories that handle conversion
//  between the following types of AppleEvent descriptors and Foundation types:
//
//   - AppleEvent record descriptor (typeAERecord) and NSDictionary
//   - AppleEvent list descriptor (typeAEList) and NSArray
//   - AppleEvent descriptor that may be a list, a record, or something else and id
//   - AppleEvent file URL descriptor (typeFileURL) and NSURL
// ------------------------------------------------------------

#import "ScriptingSupportCategories.h"
#import <Carbon/Carbon.h>

@implementation NSDictionary (UserDefinedRecord)

+(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc
{
    // ------------------------------------------------------------
    // Create an empty dictionary to start with:
    // ------------------------------------------------------------
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];

    // ------------------------------------------------------------
    // `keyASUserRecordFields` has a list of alternating keys
    // and values:
    // ------------------------------------------------------------
    NSAppleEventDescriptor* userFieldItems = [desc descriptorForKeyword:keyASUserRecordFields];
    NSInteger numItems = [userFieldItems numberOfItems];
    
    for ( NSInteger itemIndex = 1; itemIndex <= numItems - 1; itemIndex += 2 ) {
        NSAppleEventDescriptor* keyDesc = [userFieldItems descriptorAtIndex:itemIndex];
        NSAppleEventDescriptor* valueDesc = [userFieldItems descriptorAtIndex:itemIndex + 1];
        
        // ------------------------------------------------------------
        // Convert key and value to Foundation object, noting that the
        // value can be another record or list:
        // ------------------------------------------------------------
        NSString* keyString = [keyDesc stringValue];
        id value = [valueDesc objectValue];
        
        // ------------------------------------------------------------
        // Add the key value pair to the dictionary:
        // ------------------------------------------------------------
        if ( keyString != nil && value != nil ) {
            [dict setObject:value forKey:keyString];
        }
    }
    
    // ------------------------------------------------------------
    // Return an immutable copy:
    // ------------------------------------------------------------
    return [NSDictionary dictionaryWithDictionary:dict];
}

-(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor
{
    // ------------------------------------------------------------
    // Create an empty `AERecord` to start with and an empty
    // `AEList` to hold alternating keys and values:
    // ------------------------------------------------------------
    NSAppleEventDescriptor* recordDesc = [NSAppleEventDescriptor recordDescriptor];
    NSAppleEventDescriptor* userFieldDesc = [NSAppleEventDescriptor listDescriptor];
    NSInteger userFieldIndex = 1;
    
    // ------------------------------------------------------------
    // For each key value pair construct descriptors:
    // ------------------------------------------------------------
    for ( id key in self ) {
        if ( [key isKindOfClass:[NSString class]] ) {
            NSString* valueString = nil;
            id value = [self objectForKey:key];

            // ------------------------------------------------------------
            // Convert a key that is not a string to a string:
            // ------------------------------------------------------------
            if ( ! [value isKindOfClass:[NSString class]] ) {
                valueString = [NSString stringWithFormat:@"%@", value];
            } else {
                valueString = value;
            }
            
            NSAppleEventDescriptor* valueDesc = [NSAppleEventDescriptor descriptorWithString:valueString];
            NSAppleEventDescriptor* keyDesc = [NSAppleEventDescriptor descriptorWithString:key];
            
            // ------------------------------------------------------------
            // Stick the key and value descriptors into the `AEList`:
            // ------------------------------------------------------------
            if ( valueDesc != nil && keyDesc != nil ) {
                [userFieldDesc insertDescriptor:keyDesc atIndex:userFieldIndex++];
                [userFieldDesc insertDescriptor:valueDesc atIndex:userFieldIndex++];
            }
        }
    }
    
    // ------------------------------------------------------------
    // Stick the `AEList` into the `AERecord` with
    // `keyASUserRecordFields`:
    // ------------------------------------------------------------
    [recordDesc setDescriptor:userFieldDesc forKeyword:keyASUserRecordFields];
    
    return recordDesc;
}

@end

@implementation NSArray (UserList)

// ------------------------------------------------------------
// Scripting User List Descriptor:
// ------------------------------------------------------------
+(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc
{
    // ------------------------------------------------------------
    // Create an empty array to start with:
    // ------------------------------------------------------------
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    NSInteger numItems = [desc numberOfItems];
    
    // ------------------------------------------------------------
    // For each item in the list, convert to Foundation object
    // and add to the array:
    // ------------------------------------------------------------
    for ( NSInteger itemIndex = 1; itemIndex <= numItems; itemIndex++ ) {
        NSAppleEventDescriptor* itemDesc = [desc descriptorAtIndex:itemIndex];
        [array addObject:[itemDesc objectValue]];
    }
    
    // ------------------------------------------------------------
    // Return an immutable copy:
    // ------------------------------------------------------------
    return [NSArray arrayWithArray:array];
}

// ------------------------------------------------------------
// Scripting User List Descriptor:
// ------------------------------------------------------------
-(NSAppleEventDescriptor*)scriptingUserListDescriptor
{
    // ------------------------------------------------------------
    // Create an empty AEList to start with:
    // ------------------------------------------------------------
    NSAppleEventDescriptor* listDesc = [NSAppleEventDescriptor listDescriptor];
    NSInteger itemIndex = 1;
    
    // ------------------------------------------------------------
    // For each object in the array, construct a descriptor and
    // stick that into the `AEList`:
    // ------------------------------------------------------------
    for ( id item in self ) {
        NSAppleEventDescriptor* itemDesc = [NSAppleEventDescriptor descriptorWithObject:item];
        [listDesc insertDescriptor:itemDesc atIndex:itemIndex++];
    }
    
    return listDesc;
}

@end

// ------------------------------------------------------------
// NSAppleEventDescriptor:
// ------------------------------------------------------------
@implementation NSAppleEventDescriptor (GenericObject)

+(NSAppleEventDescriptor*)descriptorWithObject:(id)object
{
    NSAppleEventDescriptor* desc = nil;
	
    if ( [object isKindOfClass:[NSArray class]] ) {
        NSArray*    array = (NSArray*)object;
        desc = [array scriptingUserListDescriptor];
    }
    else if ( [object isKindOfClass:[NSDictionary class]] ) {
        NSDictionary*   dict = (NSDictionary*)object;
        desc = [dict scriptingUserDefinedRecordDescriptor];
    }
    else if ( [object isKindOfClass:[NSString class]] ) {
        desc = [NSAppleEventDescriptor descriptorWithString:(NSString*)object];
    }
    else if ( [object isKindOfClass:[NSURL class]] ) {
        desc = [NSAppleEventDescriptor descriptorWithURL:(NSURL*)object];
    }
    else {
        // ------------------------------------------------------------
        // Create a printed representation and construct a string
        // descriptor:
        // ------------------------------------------------------------
        NSString* valueString = [NSString stringWithFormat:@"%@", object];
        desc = [NSAppleEventDescriptor descriptorWithString:valueString];
    }
	
    return desc;
}

// ------------------------------------------------------------
// Object Value:
// ------------------------------------------------------------
-(id)objectValue
{
    DescType    descType = [self descriptorType];
    DescType    bigEndianDescType = 0;
    id          object = nil;
    
    
    switch ( descType ) {
        case typeUnicodeText:
        case typeUTF8Text:
            object = [self stringValue];
            break;
        case typeFileURL:
            object = [self urlValue];
            break;
        case typeAEList:
            object = [NSArray scriptingUserListWithDescriptor:self];
            break;
        case typeAERecord:
            object = [NSDictionary scriptingUserDefinedRecordWithDescriptor:self];
            break;
        case typeSInt16:
        case typeUInt16:
        case typeSInt32:
        case typeUInt32:
        case typeSInt64:
        case typeUInt64:
            object = [NSNumber numberWithInteger:(NSInteger)[self int32Value]];
            break;
        default:
            // ------------------------------------------------------------
            // Create `NSData` to hold the data for an unfamiliar type:
            // ------------------------------------------------------------
            bigEndianDescType = EndianU32_NtoB(descType);
            NSLog(@"[ShareDestinationKit] INFO - Creating NSData for AE desc type %.4s.", (char*)&bigEndianDescType);
            object = [self data];
            break;
    }
	
    return object;
}

@end

// ------------------------------------------------------------
// NSAppleEventDescriptor:
// ------------------------------------------------------------
@implementation NSAppleEventDescriptor (URLValue)

+ (NSAppleEventDescriptor *)descriptorWithURL:(NSURL *)url
{
    NSData* urlData = (NSData *)CFBridgingRelease((CFURLCreateData(NULL, (__bridge CFURLRef)(url), kCFStringEncodingUTF8, TRUE)));
    return [NSAppleEventDescriptor descriptorWithDescriptorType:typeFileURL data:urlData];
}

- (NSURL*)urlValue
{
    NSData      *urlData = [self data];
    NSError     *theError = nil;
    NSURL       *theURLValue = nil;
    
    switch ( [self descriptorType] ) {
        case typeFileURL:
            theURLValue = (NSURL *)CFBridgingRelease(CFURLCreateWithBytes(NULL, [urlData bytes], [urlData length], kCFStringEncodingUTF8, NULL));
            break;
    }
    
    if ( theError != nil ) {
        NSLog(@"[ShareDestinationKit] ERROR - Failed to retrieve URL value out of an NSAppleEventDescriptor %@, error %@.", self, theError);
    }
    
    return theURLValue;
}

@end
