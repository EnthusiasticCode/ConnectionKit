//
//  Created by Sam Deane on 06/11/2012.
//  Copyright 2012 Karelia Software. All rights reserved.
//

#import "CK2FileManagerBaseTests.h"
#import <SenTestingKit/SenTestingKit.h>
#import <DAVKit/DAVKit.h>

@interface CK2FileManagerWebDAVTests : CK2FileManagerBaseTests

@end

@implementation CK2FileManagerWebDAVTests

#pragma mark - Utilities

- (BOOL)setup
{
    BOOL result = [self setupSessionWithResponses:@"webdav"];
    STAssertTrue(result, @"failed to setup");

    return result;
}

- (void)doTestCreateAndRemoveFileAtURL:(NSURL*)url
{
    if ([self setup])
    {
        NSData* data = [@"Some test text" dataUsingEncoding:NSUTF8StringEncoding];

        // try to delete in case it's left around from last time - ignore error
        [self.session removeItemAtURL:url completionHandler:^(NSError *error) {
            [self pause];
        }];
        [self runUntilPaused];

        // try to upload
        [self.session createFileAtURL:url contents:data withIntermediateDirectories:YES openingAttributes:nil progressBlock:nil completionHandler:^(NSError *error) {
            STAssertNil(error, @"got unexpected error %@", error);

            [self pause];
        }];
        [self runUntilPaused];

        // try to download
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
            STAssertNil(error, @"got unexpected error %@", error);

            NSString* received = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            STAssertTrue([received isEqualToString:@"Some test text"], @"string should have matched, was %@", received);

            [self pause];
        }];
        [self runUntilPaused];

        // try to delete - this time we do want to check the error
        [self.session removeItemAtURL:url completionHandler:^(NSError *error) {
            STAssertNil(error, @"got unexpected error %@", error);
            [self pause];
        }];
        [self runUntilPaused];
        
    }
}

- (void)doTestCreateAndRemoveDirectoryAtURL:(NSURL*)url
{
    // delete directory in case it's left from last time
    [self.session removeItemAtURL:url completionHandler:^(NSError *error) {
        [self pause];
    }];
    [self runUntilPaused];

    // try to make it
    [self.session createDirectoryAtURL:url withIntermediateDirectories:YES openingAttributes:nil completionHandler:^(NSError *error) {
        STAssertNil(error, @"got unexpected error %@", error);

        [self pause];
    }];
    [self runUntilPaused];

    // switch the responder so that the next delete fails (has no effect if we're using the real server)
    [self useResponseSet:@"make fails"];

    // try to make it again - should fail
    [self.session createDirectoryAtURL:url withIntermediateDirectories:YES openingAttributes:nil completionHandler:^(NSError *error) {
        STAssertNotNil(error, @"should have error");
        STAssertTrue([[error domain] isEqual:DAVClientErrorDomain], @"");
        STAssertEquals([error code], (NSInteger) 405, @"should have error 405, got %ld", (long) [error code]);

        [self pause];
    }];
    [self runUntilPaused];

    // try to delete directory - should work this time
    [self.session removeItemAtURL:url completionHandler:^(NSError *error) {
        STAssertNil(error, @"got unexpected error %@", error);
        [self pause];
    }];
    [self runUntilPaused];
}

#pragma mark - Tests

- (void)testContentsOfDirectoryAtURL
{
    if ([self setup])
    {
        NSURL* url = [self URLForPath:@""];
        NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsSubdirectoryDescendants;

        // do the test with the wrong password
        self.password = @"wrong";
        [self.session contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:options completionHandler:^(NSArray *contents, NSError *error) {

            STAssertNotNil(error, @"should have error");
            STAssertTrue([error.domain isEqualToString:NSURLErrorDomain], @"unexpected domain %@", error.domain);
            STAssertTrue(error.code == NSURLErrorUserCancelledAuthentication, @"unexpected code %ld", (long) error.code);
            [self pause];
        }];
        [self runUntilPaused];

        // do test with the right password
        self.password = @"demo";
        [self.session contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:options completionHandler:^(NSArray *contents, NSError *error) {

            if (error)
            {
                STFail(@"got error %@", error);
            }
            else
            {
                NSUInteger count = [contents count];
                STAssertTrue(count > 0, @"should have results");
                STAssertTrue(![contents containsObject:url], @"contents shouldn't include url of directory itself, they were: %@", contents);
            }
            
            [self pause];
        }];
        [self runUntilPaused];
    }
}

- (void)testCreateAndRemoveDirectoryAtURL
{
    if ([self setup])
    {
        NSURL* url = [self URLForPath:@"ck-test-directory"];
        [self doTestCreateAndRemoveDirectoryAtURL:url];
    }
}

- (void)testCreateAndRemoveDirectoryAndSubdirectoryAtURL
{
    if ([self setup])
    {
        NSURL* url = [self URLForPath:@"ck-test-directory/ck-test-subdirectory"];
        [self doTestCreateAndRemoveDirectoryAtURL:url];
    }
}

- (void)testCreateAndRemoveFileAtURL
{
    if ([self setup])
    {
        NSURL* url = [self URLForPath:@"ck-test-file.txt"];
        [self doTestCreateAndRemoveFileAtURL:url];
    }
}

- (void)testCreateAndRemoveFileAtURLInSubdirectory
{
    if ([self setup])
    {
        NSURL* url = [self URLForPath:@"ck-test-directory/ck-test-file.txt"];
        [self doTestCreateAndRemoveFileAtURL:url];
    }
}

@end