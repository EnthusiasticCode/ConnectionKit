//
//  KTDocWindow.h
//  Marvel
//
//  Created by Dan Wood on 10/11/04.
//  Copyright 2004 Biophony, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KTWebView;

@interface KTDocWindow : NSWindow {

	IBOutlet KTWebView *oWebKitView;
}


@end
