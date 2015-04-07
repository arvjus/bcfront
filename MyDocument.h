//
//  MyDocument.h
//  bcfront
//
//  Created by Arvid Juskaitis on 2/9/14.
//  Copyright __MyCompanyName__ 2014 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface MyDocument : NSDocument
{
	IBOutlet NSTextView * editorTextView;
	IBOutlet NSTextView * outputTextView;
	
    NSData * dataFromFile;
}

- (IBAction)calculate:(id)sender;
- (IBAction)clearOutput:(id)sender;

@end
