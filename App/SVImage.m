// 
//  SVImage.m
//  Sandvox
//
//  Created by Mike on 27/01/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "SVImage.h"

#import "SVApplicationController.h"
#import "SVImageDOMController.h"
#import "SVLink.h"
#import "SVMediaGraphicInspector.h"
#import "SVMediaRecord.h"
#import "SVSiteItem.h"
#import "SVTextAttachment.h"
#import "SVWebEditorHTMLContext.h"
#import "KSWebLocation.h"

#import "NSManagedObject+KTExtensions.h"

#import "NSBitmapImageRep+Karelia.h"
#import "NSError+Karelia.h"
#import "NSString+Karelia.h"
#import "NSURL+Karelia.h"


@interface SVImage ()
@end


#pragma mark -


@implementation SVImage 

+ (NSArray *)plugInKeys;
{
    return [[super plugInKeys] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:
                                                              @"alternateText",
                                                              @"link",
                                                              nil]];
}

- (void)dealloc;
{
    [_altText release];
    
    [super dealloc];
}

#pragma mark Media

- (void)didSetSource;
{
    [super didSetSource];
    
    // Adjust file type if not valid
    if (![self validateTypeToPublish:[[self container] typeToPublish]])
    {
        [[self container] setTypeToPublish:(NSString *)kUTTypeJPEG];
    }
    
    // External images become auto sized
    if (![self media] && [self externalSourceURL])
    {
        [[self container] setConstrainProportions:NO];
        [self setWidth:0];
        [self setHeight:0];
    }
}

+ (NSArray *)allowedFileTypes
{
	return [NSBitmapImageRep imageTypes];
}

- (BOOL)validateTypeToPublish:(NSString *)type;
{
    BOOL result = ([type isEqualToString:(NSString *)kUTTypeJPEG] ||
                   [type isEqualToString:(NSString *)kUTTypePNG] ||
                   [type isEqualToString:(NSString *)kUTTypeGIF]);
    
    return result;
}

#pragma mark Alt Text

@synthesize alternateText = _altText;

#pragma mark Placement

- (BOOL)shouldWriteHTMLInline;
{
    BOOL result = [super shouldWriteHTMLInline];
    
    // Images become inline once you turn off all additional stuff like title & caption
    if (![[self container] isPagelet])
    {
        SVTextAttachment *attachment = [[self container] textAttachment];
        if (![[attachment causesWrap] boolValue])
        {
            result = YES;
        }
        else
        {
            SVGraphicWrap wrap = [[attachment wrap] intValue];
            result = (wrap == SVGraphicWrapRight ||
                      wrap == SVGraphicWrapLeft ||
                      wrap == SVGraphicWrapNone);
        }
    }
    
    return result;
}

- (BOOL)canWriteHTMLInline; { return YES; }

+ (NSSet *)keyPathsForValuesAffectingIsPagelet;
{
    return [NSSet setWithObjects:
            @"placement",
            @"showsTitle",
            @"showsIntroduction",
            @"showsCaption", nil];
}

#pragma mark Link

@synthesize link = _link;

- (id)serializedValueForKey:(NSString *)key;
{
    if ([key isEqualToString:@"link"])
    {
        SVLink *link = [self link];
        // If the link is to a page, actually archive a different link that references the ID-only
        if ([link page])
        {
            link = [SVLink linkWithURLString:[link URLString] openInNewWindow:[link openInNewWindow]];
        }
        
        NSData *data = (link ? [NSKeyedArchiver archivedDataWithRootObject:link] : nil);
        return data;
    }
    else
    {
        return [super serializedValueForKey:key];
    }
}

- (void)setSerializedValue:(id)serializedValue forKey:(NSString *)key;
{
    if ([key isEqualToString:@"link"])
    {
        SVLink *result = nil;
        if (serializedValue)
        {
            result = [NSKeyedUnarchiver unarchiveObjectWithData:serializedValue];
            
            SVSiteItem *page = [SVSiteItem siteItemForPreviewPath:[result URLString]
                                           inManagedObjectContext:[[self container] managedObjectContext]];
            
            if (page) result = [SVLink linkWithSiteItem:page openInNewWindow:[result openInNewWindow]];
        }
        
        [self setLink:result];
    }
    else
    {
        [super setSerializedValue:serializedValue forKey:key];
    }
}

#pragma mark Publishing

- (NSBitmapImageFileType)storageType;
{
    NSBitmapImageFileType result = [NSBitmapImageRep typeForUTI:[[self container] typeToPublish]];
    return result;
}
- (void) setStorageType:(NSBitmapImageFileType)storageType;
{
    [[self container] setTypeToPublish:[NSBitmapImageRep ks_typeForBitmapImageFileType:storageType]];
}
+ (NSSet *)keyPathsForValuesAffectingStorageType;
{
    return [NSSet setWithObject:@"typeToPublish"];
}

@dynamic compressionFactor;

#pragma mark HTML

- (void)writeHTML:(SVHTMLContext *)context
{
    // Link
    BOOL isPagelet = [[self container] isPagelet];
    if (isPagelet && [self link])
    {
        [context startAnchorElementWithHref:[[self link] URLString] title:nil target:nil rel:nil];
    }
    
    
    // Actually write the image
    NSString *alt = [self alternateText];
    if (!alt) alt = @"";
    
    if ([self shouldWriteHTMLInline]) [[self container] buildClassName:context];
    
    [context buildAttributesForElement:@"img" bindSizeToObject:self DOMControllerClass:[SVImageDOMController class]];
    
    SVMediaRecord *media = [self media];
    if (media)
    {
        [context writeImageWithSourceMedia:media
                                       alt:alt
                                     width:self.container.width
                                    height:self.container.height
                                      type:[[self container] typeToPublish]];
    }
    else
    {
        NSURL *URL = [self externalSourceURL];
        
        [context writeImageWithSrc:(URL ? [context relativeURLStringOfURL:URL] : @"")
                               alt:alt
                             width:self.container.width
                            height:self.container.height];
    }
    
    [context addDependencyOnObject:self keyPath:@"media"];
    
    
    if ([[self container] isPagelet] && [self link]) [context endElement];
}

- (BOOL)shouldPublishEditingElementID; { return NO; }

#pragma mark Inspector

+ (SVInspectorViewController *)makeInspectorViewController;
{
    SVInspectorViewController *result = [[[SVMediaGraphicInspector alloc]
                                          initWithNibName:@"SVImage" bundle:nil]
                                         autorelease];
    
    return result;
}

@end
