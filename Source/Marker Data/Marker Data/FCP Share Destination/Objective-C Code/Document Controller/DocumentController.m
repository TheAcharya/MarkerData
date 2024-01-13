//
//  DocumentController.m
//  ShareDestinationKit
//
//  Created by Chris Hocking on 10/12/2023.
//

#import "DocumentController.h"
#import "Document.h"

@implementation DocumentController

// ------------------------------------------------------------
// Read from URL:
// ------------------------------------------------------------
- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"[ShareDestinationKit] INFO - readFromURL triggered!");
    return YES;
}

// ------------------------------------------------------------
// Write to URL:
// ------------------------------------------------------------
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"[ShareDestinationKit] INFO - writeToURL triggered!");
    return YES;
}

// ------------------------------------------------------------
// Open Document with Contents of URL:
// ------------------------------------------------------------
- (void)openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error))completionHandler
{
    NSLog(@"[ShareDestinationKit] INFO - openDocumentWithContentsOfURL triggered!");
    
	NSError *theErr = nil;
	NSString *documentType = [self typeForContentsOfURL:url error:&theErr];
    
    if (theErr != nil) {
        NSLog(@"[ShareDestinationKit] ERROR in openDocumentWithContentsOfURL: %@", theErr.localizedDescription);
    }
    
	if ( documentType == nil ) {
		completionHandler(nil, NO, theErr);
		return;
	}

	if ( [documentType isEqualToString:@"Asset Media File"] || [documentType isEqualToString:@"Asset Description File"] ) {
        
        NSLog(@"[ShareDestinationKit] INFO - It's an Asset Media File or Asset Description File!");
        
		Document *currentDocument = [self currentDocument];
		
		if ( currentDocument == nil ) {
			NSArray *documents = [self documents];
			
            if ( [documents count] > 0 ) {
                currentDocument = [documents objectAtIndex:0];
            } else {
                currentDocument = [self openUntitledDocumentAndDisplay:YES error:&theErr];
            }
		}
		
		NSUInteger assetIndex = [currentDocument addURL:url content:YES metadata:nil dataOptions:nil];
        
		completionHandler([currentDocument.assets objectAtIndex:assetIndex], NO, theErr);
	} else {
        NSLog(@"[ShareDestinationKit] INFO - It's NOT an Asset Media File or Asset Description File, so calling the super method...");
		[super openDocumentWithContentsOfURL:url display:displayDocument completionHandler:completionHandler];
	}
}

@end
