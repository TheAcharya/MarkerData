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
#import "MediaAssetHelperKeys.h"

@implementation MakeCommand

// ------------------------------------------------------------
// Perform Default Implementation:
// ------------------------------------------------------------
- (id)performDefaultImplementation {
    id		result = nil;
    
    NSLog(@"[ShareDestinationKit] INFO - MakeCommand performDefaultImplementation");
    
    // Notify OpenEventHandler to setup hander
    // This is to make sure when FCP tries to send the file it is received
    NSLog(@"[ShareDestinationKit] INFO - Send start notification");
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"FCPShareStart" object:self];
    
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
        
        // Get export folder from User Defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *homeDirectory = NSHomeDirectory();
        
        NSString *exportFolderURLString = [defaults objectForKey:@"exportFolderURL"];
        exportFolderURLString = [exportFolderURLString stringByReplacingOccurrencesOfString:@"~" withString:homeDirectory];
        
        NSURL *exportFolderURL;
        
        if ([exportFolderURLString length] == 0) {
            // If export folder is empty default to Chache folder
            exportFolderURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Library/Caches/Marker Data/FCPTempExport/%@", homeDirectory, nameParameter]];
        } else {
            exportFolderURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/_FCPExport/%@", exportFolderURLString, nameParameter]];
        }
        
        // Create directory if missing
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[exportFolderURL path]]) {
            NSLog(@"[ShareDestinationKit] NOTICE Eport destination missing, attempting to create it: %@", [exportFolderURL path]);
            
            NSError *error;
            [fileManager createDirectoryAtURL:exportFolderURL withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"[ShareDestinationKit] ERROR Error creating export directory: %@", error);
                return nil;
            }
        }
        
        NSString *outputFileURL = [[exportFolderURL path] stringByAppendingPathComponent:nameParameter];
        
        NSLog(@"[ShareDestinationKit] INFO - Writing files to directory: %@", outputFileURL);
        
        NSDictionary *desktopLocation =  [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSURL fileURLWithPath:outputFileURL],               kMediaAssetLocationFolderKey,
                                         @"",                                                 kMediaAssetLocationBasenameKey,
                                         [NSNumber numberWithBool:YES],                       kMediaAssetLocationHasMediaKey,
                                         [NSNumber numberWithBool:YES],                       kMediaAssetLocationHasDescriptionKey,
                                         nil];

        NSInteger assetIndex = [currentDocument addAssetAtLocation:desktopLocation
                                                           content:FALSE
                                                          metadata:metadataParameter
                                                       dataOptions:dataOptionsParameter];
        Asset *newAsset = [currentDocument.assets objectAtIndex:assetIndex];
        
        result = [newAsset objectSpecifier];
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

