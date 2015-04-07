//
//  MyDocument.m
//  bcfront
//
//  Created by Arvid Juskaitis on 2/9/14.
//  Copyright __MyCompanyName__ 2014 . All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    if (dataFromFile) {
        NSString * text = [[NSString alloc]initWithData:dataFromFile encoding:NSUTF8StringEncoding];
		[editorTextView setString:text]; 
		[text release];
	}
	[editorTextView setAllowsUndo:YES]; 
	[editorTextView setFont:[NSFont fontWithName:@"Courier" size:12]];
	[outputTextView setFont:[NSFont fontWithName:@"Courier" size:12]];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    NSString * text = [editorTextView string];
	return [text dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	dataFromFile = [data retain];
    return YES;
}

- (void)dealloc
{
	[dataFromFile release];
	[super dealloc];
}

- (IBAction)calculate:(id)sender
{
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/bin/bc"];
	
	NSArray *arguments = [NSArray arrayWithObjects: @"-lq", nil];
	[task setArguments: arguments];

	NSPipe *stdinpipe = [NSPipe pipe];
	[task setStandardInput: stdinpipe];
	NSFileHandle *stdinhandle = [stdinpipe fileHandleForWriting];

	NSRange selectedRange = [editorTextView selectedRange];
	NSString * text;
	if (selectedRange.length)
		text = [[editorTextView string] substringWithRange:selectedRange];
	else
		text = [editorTextView string];
	[stdinhandle writeData:[[text stringByAppendingString:@"\nquit\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSPipe *stdoutpipe = [NSPipe pipe];
	[task setStandardOutput: stdoutpipe];
	NSFileHandle *stdouthandle = [stdoutpipe fileHandleForReading];
	
	NSPipe *stderrpipe = [NSPipe pipe];
	[task setStandardError: stderrpipe];
	NSFileHandle *stderrhandle = [stderrpipe fileHandleForReading];
	
	[task launch];
	
	NSData *stdoutdata = [stdouthandle readDataToEndOfFile];
	NSString *stdouttext = [[NSString alloc] initWithData: stdoutdata encoding: NSUTF8StringEncoding];
	NSData *stderrdata = [stderrhandle readDataToEndOfFile];
	NSString *stderrtext = [[NSString alloc] initWithData: stderrdata encoding: NSUTF8StringEncoding];
	[outputTextView setString:[stdouttext stringByAppendingString:stderrtext]]; 

	[stdouttext release];
	[stderrtext release];
	[task release];	
}

- (IBAction)clearOutput:(id)sender
{
	NSString * text = [[NSString alloc]init];
	[outputTextView setString:text]; 
	[text release];
}

@end
