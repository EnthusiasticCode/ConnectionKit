//
//  CollectionIndex.m
//  IndexElement
//
//  Copyright 2006-2010 Karelia Software. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  *  Redistribution of source code must retain the above copyright notice,
//     this list of conditions and the follow disclaimer.
//
//  *  Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other material provided with the distribution.
//
//  *  Neither the name of Karelia Software nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS-IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUR OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Community Note: This code is distrubuted under a modified BSD License.
//  We encourage you to share your Sandvox Plugins similarly.
//

#import "CollectionIndexPlugIn.h"

// LocalizedStringInThisBundle(@"Please specify the collection to index using the PlugIn Inspector.", "String_On_Page_Template")


@implementation CollectionIndexPlugIn


#pragma mark SVIndexPlugIn

+ (NSArray *)plugInKeys
{ 
    NSArray *plugInKeys = [NSArray arrayWithObjects:
                           @"maxItems", 
                           @"enableMaxItems", 
                           @"includeSummaries", 
                           @"maxSummaryCharacters", 
                           nil];
    
    return [[super plugInKeys] arrayByAddingObjectsFromArray:plugInKeys];
}


#pragma mark HTML Generation

- (void)writeHTML:(id <SVPlugInContext>)context
{
    [super writeHTML:context];
    
    // add dependencies
    [context addDependencyForKeyPath:@"maxItems" ofObject:self];
    [context addDependencyForKeyPath:@"enableMaxItems" ofObject:self];
    [context addDependencyForKeyPath:@"includeSummaries" ofObject:self];
    [context addDependencyForKeyPath:@"maxSummaryCharacters" ofObject:self];
}


#pragma mark Properties

// hoping this overrides SVIndexPlugIn accessor properly
- (void)setIndexedCollection:(id <SVPage>)collection
{
    // when we change indexedCollection, set the containers title to the title of the collection, or to
    // KTPluginUntitledName if collection is nil

    [super setIndexedCollection:collection];
    if ( collection )
    {
        [self.container setTitle:[collection title]];
    }
    else
    {
        NSString *defaultTitle = [[self bundle] objectForInfoDictionaryKey:@"KTPluginUntitledName"];
        [self.container setTitle:defaultTitle];
    }
}

@synthesize maxItems = _maxItems;
- (NSUInteger)maxItems
{
    // return 0 if user has disabled maximum
    return (self.enableMaxItems) ? _maxItems : 0;
}

@synthesize enableMaxItems = _enableMaxItems;
@synthesize includeSummaries = _includeSummaries;
@synthesize maxSummaryCharacters = _maxSummaryCharacters;

@end
