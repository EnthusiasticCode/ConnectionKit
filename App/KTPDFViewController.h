//
//  KTPDFViewController.h
//  Marvel
//
//  Created by Terrence Talbot on 1/6/06.
//  Copyright 2006 Biophony LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface KTPDFViewController : NSWindowController 
{
    IBOutlet PDFView *oPDFView;
}

// subclasses must override:

/*! returns shared instance that owns nib */
+ (id)sharedController;

/*! override to load oTextView with relevant content */
- (void)windowDidLoad;

@end
