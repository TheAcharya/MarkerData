//
//  Object.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#pragma once

#import <Foundation/Foundation.h>

// ------------------------------------------------------------
// The Object class is the root class for all of the
// AppleScript objects we provide in our application.
//
// It is in this class that take care of most of the
// 'infrastructure' type operations needed for maintaining
// our objects.  In our application we assume that all of
// our objects will have a 'name' property and an 'id'
// property and we maintain those properties in this class.
//
// Given that's taken care of here, we implement the
// objectSpecifier method based on the id property. By
// doing that here, we don't have to worry about
// implementing an objectSpecifier method in any of our
// other sub-classes.
//
// For most intentions and purposes, you should be able
// to use this class unmodified as a superclass for your
// own scriptable objects.
// ------------------------------------------------------------

@interface Object : NSObject

// ------------------------------------------------------------
// STORAGE MANAGEMENT:
//
// The normal sequence of events when an object is created is
// as follows:
//
// 1. an AppleScript 'make' command will allocate and
//    initialize an instance of the class it has been asked 
//    to create.  For example, it may create a Trinket.
//
// 2. then it will call the:
//    `insertInXXXXX: insertInXXXXX:atIndex:` method on the
//     container object where the new object will be stored.
//     For example, if we were being asked to create a
//     Trinket in a Bucket, then the make command would
//     create an instance of Trinket and then it would
//     call insertInTrinkets: on the Bucket object.
//
// 3. Inside of the:
//    ``insertInXXXXX:` or `insertInXXXXX:atIndex:` you
//    must record the parent object and the parent's
//    property key for the new object being created so
//    you can create a objectSpecifier later. In this
//    class, we have defined the `setContainer:andProperty:`
//    for that purpose. For example, inside of our
//    `insertInTrinkets:` method on our Bucket object,
//    we the `setContainer:andProperty:` method on the
//    trinket object like so:
//
//    `[trinket setContainer:self andProperty:@"trinkets"]`
//
//     to inform the trinket object who its container
//     is and the name of the Cocoa key on that container
//     object used for the list of trinkets.
// ------------------------------------------------------------

-(instancetype)init;
- (void)dealloc;

// ------------------------------------------------------------
// Ensuring that the id values we are using for unique ids
// are unique is essential go good operation. Here we provide
// a class method to vend unique id values for use with our
// objects.
// ------------------------------------------------------------
+ (NSString *)calculateNewUniqueID;

// ------------------------------------------------------------
// Properties for the container and containerProperty fields:
// ------------------------------------------------------------
@property (readonly) id container;
@property (readonly) NSString *containerProperty;

// ------------------------------------------------------------
// Since the container and containerProperty fields are always
// set at the same time, we have lumped those setter calls
// together into one call that sets both.
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
// calling objectSpecifier asks an object to return an object
// specifier record referring to itself. You must call
// `setContainer:andProperty:` before you can call this
// method. see the explanation above.
//
// Note: this routine assumes you have added a
// `objectSpecifier` method to a category of `NSApplication`
// that always returns `nil` (the default value for the
// application class).
// ------------------------------------------------------------
- (NSScriptObjectSpecifier *)objectSpecifier;

@end
