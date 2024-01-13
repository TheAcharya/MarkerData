//
//  MakeCommand.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "MakeCommand.h"
#import "DocumentController.h"
#import "Document.h"
#import "Asset.h"
#import "ScriptingSupportCategories.h"

@implementation MakeCommand

// ------------------------------------------------------------
// Perform Default Implementation:
// ------------------------------------------------------------
- (id)performDefaultImplementation {
    id		result = nil;
    
    NSLog(@"[ShareDestinationKit] INFO - MakeCommand performDefaultImplementation");
    
    NSDictionary * theArguments = [self evaluatedArguments];
    
    // ------------------------------------------------------------
    // Show the direct parameter and arguments:
    // ------------------------------------------------------------
    NSLog(@"[ShareDestinationKit] INFO - The direct parameter is: '%@'", [self directParameter]);
    NSLog(@"[ShareDestinationKit] INFO - The other parameters are: '%@'", theArguments);
    
    id classParameter = [theArguments objectForKey:@"ObjectClass"];
    NSDictionary* properties = [theArguments objectForKey:@"KeyDictionary"];
    
    if ( classParameter == nil ) {
        NSLog(@"[ShareDestinationKit] INFO - No object class specified, so aborting!");
        [self setScriptErrorNumber:errAEParamMissed];
        return nil;
    }
    
    FourCharCode classCode = (FourCharCode)[classParameter integerValue];
    
    if ( [[NSScriptClassDescription classDescriptionForClass:[Asset class]] matchesAppleEventCode:classCode] ) {
        
        NSLog(@"[ShareDestinationKit] INFO - classes match");
        
        DocumentController *docController = [DocumentController sharedDocumentController];
        Document *currentDocument = [docController currentDocument];
        
        if ( currentDocument == nil ) {
            NSArray *documents = [docController documents];
            if ( [documents count] > 0 ) {
                // ------------------------------------------------------------
                // Pick up the first document if current document is nil:
                // ------------------------------------------------------------
                currentDocument = [documents objectAtIndex:0];
                NSLog(@"[ShareDestinationKit] INFO - Picking the first document...");
            } else {
                // ------------------------------------------------------------
                // Create an untitled document:
                // ------------------------------------------------------------
                currentDocument = [docController openUntitledDocumentAndDisplay:YES error:nil];
                NSLog(@"[ShareDestinationKit] INFO - Creating a new document...");
            }
        }
        
        // ------------------------------------------------------------
        // Invoke the new asset sheet and suspend script execution:
        // ------------------------------------------------------------
        id nameParameter = nil;
        id metadataParameter = nil;
        id dataOptionsParameter = nil;
        
        if ( properties != nil ) {
            NSLog(@"[ShareDestinationKit] INFO - properties aren't nil");
                  
            nameParameter = [properties objectForKey:@"name"];
            metadataParameter = [properties objectForKey:@"metadata"];
            dataOptionsParameter = [properties objectForKey:@"dataOptions"];
            
            NSLog(@"[ShareDestinationKit] INFO - nameParameter: %@", nameParameter);
            NSLog(@"[ShareDestinationKit] INFO - metadataParameter: %@", metadataParameter);
            NSLog(@"[ShareDestinationKit] INFO - dataOptionsParameter: %@", dataOptionsParameter);
        }
        
        // ------------------------------------------------------------
        // Get the user interaction level and see if we can bring up
        // our user interface:
        // ------------------------------------------------------------
        NSUInteger interactionLevel = [self appleEventUserInteractionLevel];
        
        if ( interactionLevel == kAECanInteract ||interactionLevel == kAEAlwaysInteract || interactionLevel == kAECanSwitchLayer ) {
            
            NSLog(@"[ShareDestinationKit] INFO - Apple Script says we're allowed to interact with the user!");
            
            // ------------------------------------------------------------
            // If we wanted to, we could implement our window controller
            // here:
            // ------------------------------------------------------------
            WindowController *currentWindowController = currentDocument.primaryWindowController;
            
            // ------------------------------------------------------------
            // Suspend the script execution and invoke the user interface:
            // ------------------------------------------------------------
            [self suspendExecution];
            
            // ------------------------------------------------------------
            // If we wanted to, we could show our user interface here:
            // ------------------------------------------------------------
            [currentWindowController newAssetWithName:nameParameter
                                             metadata:metadataParameter
                                          dataOptions:dataOptionsParameter
                                    completionHandler:^(Asset *newAsset) {
                if ( newAsset != nil ) {
                    NSScriptObjectSpecifier *theSpec = [newAsset objectSpecifier];
                    
                    // ------------------------------------------------------------
                    // Resume the execution with the result:
                    // ------------------------------------------------------------
                    [self resumeExecutionWithResult:theSpec];
                } else {
                    // ------------------------------------------------------------
                    // Indicate that the user has canceled the operation and 
                    // resume script execution:
                    // ------------------------------------------------------------
                    [self setScriptErrorNumber:userCanceledErr];
                    [self resumeExecutionWithResult:nil];
                }
            }];
            
            
        } else {
            
            NSLog(@"[ShareDestinationKit] INFO - Apple Script says we're NOT allowed to interact with the user");
            
            // ------------------------------------------------------------
            // Create a new asset at a default location if user
            // interaction is not allowed:
            // ------------------------------------------------------------
            NSDictionary *defaultLocation = [currentDocument defaultAssetLocation];
            NSInteger assetIndex = [currentDocument addAssetAtLocation:defaultLocation
                                                               content:FALSE
                                                              metadata:metadataParameter
                                                           dataOptions:dataOptionsParameter];
            Asset *newAsset = [currentDocument.assets objectAtIndex:assetIndex];
            
            result = [newAsset objectSpecifier];
        }
    }
    else {
        // ------------------------------------------------------------
        // Invoke the standard implementation by the super class:
        // ------------------------------------------------------------
        result = [super performDefaultImplementation];
        NSLog(@"[ShareDestinationKit] INFO - Invoke the standard implementation by the super class");
    }
    return result;
}

// ------------------------------------------------------------
// Apple Event User Interaction Level:
// ------------------------------------------------------------
- (NSUInteger)appleEventUserInteractionLevel
{
    NSLog(@"[ShareDestinationKit] INFO - appleEventUserInteractionLevel triggered");
    NSAppleEventManager     *aem = [NSAppleEventManager sharedAppleEventManager];
    NSAppleEventDescriptor  *currentEvent = [aem currentAppleEvent];
    NSAppleEventDescriptor  *interactionLevel = [currentEvent attributeDescriptorForKeyword:keyInteractLevelAttr];
    return [interactionLevel int32Value];
}

@end

