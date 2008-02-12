//
//  KTImageTextCell.h
//  BiophonyAppKit
//
//  Copyright (c) 2004 Biophony LLC. All rights reserved.
//

// from Apple's ImageAndTextCell class

#import <AppKit/AppKit.h>

@interface KTImageTextCell : NSTextFieldCell
{
    @private
    NSImage		*myImage;
    NSImageCell	*myImageCell;
	float		myMaxImageSize;
    int			myPadding;
	int			myStaleness;
	BOOL		myIsDraft;
	BOOL		myIsRoot;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

- (float)maxImageSize;
- (void)setMaxImageSize:(float)width;

- (int)staleness;
- (void)setStaleness:(int)aStaleness;

- (BOOL)isDraft;
- (void)setDraft:(BOOL)flag;

- (void)setPadding:(int)anInt;
- (int)padding;

- (BOOL)isRoot;	// The root page has extra padding at the top
- (void)setRoot:(BOOL)isRoot;

@end
