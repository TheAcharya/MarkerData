//
//  ApplicationDelegate.h
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "ApplicationDelegate.h"
#import "ScriptingSupportCategories.h"

#import <Cocoa/Cocoa.h>

//@implementation ApplicationDelegate
//
//- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
//}
//
//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    // Check if the app was launched by dropping a file onto the icon
//    if ([[NSAppleEventManager sharedAppleEventManager] currentAppleEvent]) {
//        NSAppleEventDescriptor* event = [[NSAppleEventManager sharedAppleEventManager] currentAppleEvent];
//        if ([event eventClass] == kCoreEventClass && [event eventID] == kAEOpenDocuments) {
//            // Get a descriptor for the list of files that were dropped on the icon
//            NSAppleEventDescriptor* list = [event paramDescriptorForKeyword:keyDirectObject];
//            for (NSInteger i = 1; i <= [list numberOfItems]; i++) {
//                // Get the URL of the file
//                NSURL *fileURL = [NSURL URLWithString:[[list descriptorAtIndex:i] stringValue]];
//                // Handle the file without opening a new window
//            }
//        }
//    }
//}
//
//@end
//
//// ------------------------------------------------------------
//// Application Did Finish Launching:
//// ------------------------------------------------------------
//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    NSLog(@"[ShareDestinationKit] INFO - applicationDidFinishLaunching triggered!");
//    [NSApp setDelegate:self];
//}
//
//// ------------------------------------------------------------
//// Application should quit after last window closed:
//// ------------------------------------------------------------
//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
//    NSLog(@"[ShareDestinationKit] INFO - applicationShouldTerminateAfterLastWindowClosed triggered!");
//    return YES;
//}
//
//// ------------------------------------------------------------
//// Open URLs:
//// ------------------------------------------------------------
//- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
//    NSLog(@"[ShareDestinationKit] INFO - Open URLs: %@", urls);
//}
//
//// ------------------------------------------------------------
//// Open a list of files.
//// Also stick a list of object specifiers for opened object,
//// if there is incoming OpenDoc AppleEvent.
//// ------------------------------------------------------------
//- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
//{
//    NSLog(@"[ShareDestinationKit] INFO - openFiles triggered - filenames: %@", filenames);
//    
//    NSAppleEventManager *aemanager          = [NSAppleEventManager sharedAppleEventManager];
//    NSAppleEventDescriptor *currentEvent    = [aemanager currentAppleEvent];
//    NSAppleEventDescriptor *currentReply    = [aemanager currentReplyAppleEvent];
//    NSAppleEventDescriptor *directParams    = [currentEvent descriptorForKeyword:keyDirectObject];
//    NSAppleEventDescriptor *resultDesc      = [currentReply descriptorForKeyword:keyDirectObject];
//    
//    if ( currentEvent != nil && directParams != nil ) {
//        NSArray *urls = [NSArray scriptingUserListWithDescriptor:directParams];
//        NSLog(@"[ShareDestinationKit] INFO - Open Document URLs: %@", urls);
//    }
//    
//    if ( resultDesc == nil ) {
//        resultDesc = [NSAppleEventDescriptor listDescriptor];
//    }
//    
//    NSDocumentController *docController = [NSDocumentController sharedDocumentController];
//    
//    [self openFileInFileNameList:filenames
//                         atIndex:0
//                  withController:docController
//                     docDescList:directParams
//                  resultDescList:resultDesc];
//    
//    [currentReply setDescriptor:resultDesc forKeyword:keyDirectObject];
//    
//    if ( currentReply != nil && resultDesc != nil ) {
//        NSLog(@"[ShareDestinationKit] INFO - Opened Objects: %@.", resultDesc);
//    }
//}
//
//// ------------------------------------------------------------
//// Open File in File Name List:
//// ------------------------------------------------------------
//- (void)openFileInFileNameList:(NSArray*)filenames
//                       atIndex:(NSUInteger)index
//                withController:(NSDocumentController*)docController
//                   docDescList:(NSAppleEventDescriptor*)directParams
//                resultDescList:(NSAppleEventDescriptor*)resultDesc
//{
//    
//    NSLog(@"[ShareDestinationKit] INFO - openFileInFileNameList triggered!");
//    
//    NSLog(@"[ShareDestinationKit] INFO - filenames: %@", filenames);
//          
//    if ( index >= [filenames count] ) {
//        NSLog(@"[ShareDestinationKit] INFO - No files so aborting!");
//        return;
//    }
//    
//    NSURL *url = [[NSURL fileURLWithPath:[filenames objectAtIndex:index]] URLByResolvingSymlinksInPath];
//    
//    [docController openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error){
//        
//        if (error) {
//            NSLog(@"[ShareDestinationKit] ERROR - Problem opening document: %@", error);
//            return;
//        }
//        
//        NSLog(@"[ShareDestinationKit] INFO - docController completion handler triggered!");
//        
//        id opendObject = document;
//        NSScriptObjectSpecifier *opendObjectSpec = [opendObject objectSpecifier];
//        
//        if ( opendObjectSpec != nil ) {
//            [resultDesc insertDescriptor:[opendObjectSpec descriptor] atIndex:index + 1];
//        }
//        
//        [self openFileInFileNameList:filenames
//                             atIndex:index + 1
//                      withController:docController
//                         docDescList:directParams
//                      resultDescList:resultDesc];
//    }];
//}
//
//@end
