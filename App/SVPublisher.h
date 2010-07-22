//
//  SVPublisher.h
//  Sandvox
//
//  Created by Mike on 22/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class SVHTMLContext, SVMediaRepresentation;


@protocol SVPublisher <NSObject>

#pragma mark HTML
// When you want to publish HTML, call -beginPublishingHTMLToPath: to obtain a context to write into. It will be correctly set up to handle linking in media etc. Call -close on the context once you're done to let the publishing engine know there will be no more HTML coming.
- (SVHTMLContext *)beginPublishingHTMLToPath:(NSString *)path;


#pragma mark Media
- (NSString *)publishMediaRepresentation:(SVMediaRepresentation *)mediaRep;


#pragma mark Resource Files
- (NSString *)publishResourceAtURL:(NSURL *)fileURL;


#pragma mark Design
- (void)addCSSString:(NSString *)css;
- (void)addCSSWithURL:(NSURL *)cssURL;  // same terminology as SVHTMLContext
                                        //- (void)addGraphicalText:(NSString *)text code:(NSString *)code;


#pragma mark Generic Publishing

// Call if you need to directly publish a resource. Publishing engine will take care of creating directories, permissions, etc. for you. Publishing data may be ignored if the engine determines the server is already up-to-date.
- (void)publishData:(NSData *)data toPath:(NSString *)remotePath;
- (void)publishContentsOfURL:(NSURL *)localURL toPath:(NSString *)remotePath;

// The 2 methods above are just conveniences on these, which offer more flexibility
- (void)publishData:(NSData *)data
             toPath:(NSString *)remotePath
        contentHash:(NSData *)hash;

- (void)publishContentsOfURL:(NSURL *)localURL
                      toPath:(NSString *)remotePath
            cachedSHA1Digest:(NSData *)digest;  // save engine the trouble of calculating itself


#pragma mark Paths
- (NSString *)baseRemotePath;


@end


