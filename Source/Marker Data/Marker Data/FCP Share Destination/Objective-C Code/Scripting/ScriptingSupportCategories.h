//
//  ScriptingSupportCategories.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#pragma once

#import <Foundation/Foundation.h>

@interface NSDictionary (UserDefinedRecord)

// ------------------------------------------------------------
// AppleEvent record descriptor (typeAERecord) with arbitrary
// keys:
// ------------------------------------------------------------
+(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc;
-(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor;

@end

@interface NSArray (UserList)

// ------------------------------------------------------------
// AppleEvent list descriptor (typeAEList):
// ------------------------------------------------------------
+(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc;
-(NSAppleEventDescriptor*)scriptingUserListDescriptor;

@end

@interface NSAppleEventDescriptor (GenericObject)

// ------------------------------------------------------------
// AppleEvent descriptor that may be a record, a list, or
// other object. This is necessary to handle a list or a record
// contained in another list or record.
// ------------------------------------------------------------
+(NSAppleEventDescriptor*)descriptorWithObject:(id)object;
-(id)objectValue;

@end

@interface NSAppleEventDescriptor (URLValue)

// ------------------------------------------------------------
// AppleEvenf file URL (typeFileURL) descriptor:
// ------------------------------------------------------------
+(NSAppleEventDescriptor*)descriptorWithURL:(NSURL*)url;
-(NSURL*)urlValue;

@end
