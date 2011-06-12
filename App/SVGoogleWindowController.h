//
//  SVGoogleWindowController.h
//  Sandvox
//
//  Created by Terrence Talbot on 11/1/10.
//  Copyright 2010-2011 Karelia Software. All rights reserved.
//

// all that really happens in this window controller is that certain UI properties are bound to the site while the UI is displayed

#import <Cocoa/Cocoa.h>
@class KTSite;

@interface SVGoogleWindowController : NSWindowController 
{
    NSObjectController *_objectController;
    NSTextField *_verificationCodeField;
    NSTextField *_analyticsCodeField;
	NSTextField *_verificationPrompt;
	NSTextView *_verificationOverview;
	NSTextView *_analyticsOverview;
}

@property (assign) IBOutlet NSObjectController *objectController;
@property (assign) IBOutlet NSTextField *verificationCodeField;
@property (assign) IBOutlet NSTextField *analyticsCodeField;
@property (assign) IBOutlet NSTextView *verificationOverview;
@property (assign) IBOutlet NSTextView *analyticsOverview;

- (void)configureGoogle:(NSWindowController *)sender;
- (IBAction)closeSheet:(id)sender;

- (void)setSite:(KTSite *)master;

- (IBAction)windowHelp:(id)sender;

@end