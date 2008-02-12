//
//  KTDocSiteOutlineController+Icons.m
//  Marvel
//
//  Created by Mike on 17/01/2008.
//  Copyright 2008 Karelia Software. All rights reserved.
//

#import "KTDocSiteOutlineController.h"

#import "KTElementPlugin.h"
#import "KTMaster.h"
#import "NSObject+PerformOnMainThread.h"


@interface KTDocSiteOutlineController (IconsPrivate)

- (NSImage *)favicon;
- (NSImage *)cachedFavicon;

- (NSImage *)iconForPlugin:(KTAbstractHTMLPlugin *)bundle;
+ (KTAbstractHTMLPlugin *)defaultIconPluginForPage:(KTPage *)page;

- (NSImage *)customIconForPage:(KTPage *)page;
+ (NSImage *)maskedIconOfFile:(NSString *)path size:(float)iconSize;
+ (NSImage *)customPageIconMaskImage;
+ (NSImage *)customPageIconCoverImage;

- (void)addPageToCustomIconGenerationQueue:(KTPage *)page;
- (void)beginGeneratingCustomIconForPage:(KTPage *)page;

- (unsigned)maximumIconSize;
@end


#pragma mark -


@implementation KTDocSiteOutlineController (Icons)

#pragma mark -
#pragma mark General

- (NSImage *)iconForPage:(KTPage *)page
{
	NSImage *result = nil;
	
	// The home page always appears as some kind of favicon
	if ([page isRoot])
	{
		result = [self favicon];
	}
	else
	{
		// Custom icon if available
		KTMediaContainer *customIcon = [page customSiteOutlineIcon];
		if (customIcon)
		{
			result = [self customIconForPage:page];
		}
		// Fallback to the plugin's bundle icon
		else
		{
			result = [self iconForPlugin:[[self class] defaultIconPluginForPage:page]];
		}
	}
	
	return result;
}

/*	Exactly as it says on the tin. Go through and reset all icon caches.
 */
- (void)invalidateIconCaches
{
	[self setCachedFavicon:nil];
	[myCachedPluginIcons removeAllObjects];
	[myCachedCustomPageIcons removeAllObjects];
}

#pragma mark -
#pragma mark Favicon

- (NSImage *)favicon
{
	NSImage *result = [self cachedFavicon];
	
	// If there isn't a cached icon, try to create it
	if (!result)
	{
		KTMediaContainer *faviconSource = [[[[self managedObjectContext] root] master] favicon];
		NSString *faviconSourcePath = [[faviconSource file] currentPath];
		
		// If there is no favicon chosen, default to 32favicon
		if (!faviconSourcePath)
		{
			faviconSourcePath = [[NSBundle mainBundle] pathForImageResource:@"32favicon"];
		}
		
		// Create the thumbnail
		result = [[NSImage alloc] initWithContentsOfFile:faviconSourcePath ofMaximumSize:[self maximumIconSize]];
		[self setCachedFavicon:result];
		[result release];
	}
	
	return result;
}

- (NSImage *)cachedFavicon { return myCachedFavicon; }

- (void)setCachedFavicon:(NSImage *)icon
{
	[icon retain];
	[myCachedFavicon release];
	myCachedFavicon = icon;
}

#pragma mark -
#pragma mark Bundle Icons

- (NSImage *)iconForPlugin:(KTAbstractHTMLPlugin *)plugin
{
	NSParameterAssert(plugin);
	
	NSString *bundleIdentifier = [plugin identifier];
	NSImage *result = [myCachedPluginIcons objectForKey:bundleIdentifier];
	
	if (!result)
	{
		result = [plugin pluginIcon];
		[myCachedPluginIcons setObject:result forKey:bundleIdentifier];
	}
	
	return result;
}

/*	Support method for finding the right bundle's icon to display for a page.
 *	If the page has an index, returns the index icon. Otherwise, the page plugin's icon.
 */
+ (KTAbstractHTMLPlugin *)defaultIconPluginForPage:(KTPage *)page
{
	KTAbstractHTMLPlugin *result;
	
	if ([page isCollection] && [page index])
	{
		result = [[page index] plugin];
	}
	else
	{
		result = [page plugin];
	}
	
	return result;
}

#pragma mark -
#pragma mark Custom Icons

- (NSImage *)customIconForPage:(KTPage *)page
{
	NSString *pageID = [page uniqueID];
	NSImage *result = [myCachedCustomPageIcons objectForKey:pageID];
	
	if (!result)
	{
		NSString *iconSourcePath = [[[page customSiteOutlineIcon] file] currentPath];
		if (iconSourcePath)
		{
			// Begin generating the thumbnail in the background. In the meantime, display the default icon.
			[self addPageToCustomIconGenerationQueue:page];
			result = [self iconForPlugin:[[self class] defaultIconPluginForPage:page]];
		}
	}
	
	return result;
}

/*	Takes the image at the path and masks it to the specified size.
 */
+ (NSImage *)maskedIconOfFile:(NSString *)path size:(float)iconSize
{
	NSRect iconRect = NSMakeRect(0.0, 0.0, iconSize, iconSize);
	NSImage *result = [[NSImage alloc] initWithSize:iconRect.size];
	[result setCachedSeparately:YES];
	[result lockFocus];
	
	// Draw the mask
	[[self customPageIconMaskImage] drawInRect:iconRect fromRect:NSZeroRect
									 operation:NSCompositeSourceOver fraction:1.0];
	
	
	// Fetch the thumbnail dimensions
	CGImageSourceRef iconSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
	NSDictionary *properties = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(iconSource, 0, NULL);
	float width = [properties floatForKey:(NSString *)kCGImagePropertyPixelWidth];
	float height = [properties floatForKey:(NSString *)kCGImagePropertyPixelHeight];
	CFRelease(iconSource);
	
	
	// Figure out the max size for the thumbnail that gives a cropToFit behavior
	float largeDimension;	float smallDimension;
	if (height > width)
	{
		largeDimension = height;	smallDimension = width;
	}
	else
	{
		largeDimension = width;		smallDimension = height;
	}
	float maxSize = ceilf(largeDimension * (iconSize / smallDimension));
	
	
	// Draw the thumbnail
	NSImage *thumbnail = [[NSImage alloc] initWithContentsOfFile:path ofMaximumSize:maxSize];
	float thumbOriginX = 0.5 * (thumbnail.size.width - iconSize);
	float thumbOriginY = 0.5 * (thumbnail.size.height - iconSize);
	NSRect thumbSourceRect = NSMakeRect(thumbOriginX, thumbOriginY, iconSize, iconSize);
	[thumbnail drawInRect:iconRect fromRect:thumbSourceRect operation:NSCompositeSourceAtop fraction:1.0];
	[thumbnail release];
	
	
	
	// Draw the cover image
	[[self customPageIconCoverImage] drawInRect:iconRect fromRect:NSZeroRect
									  operation:NSCompositeSourceOver fraction:1.0];
	
	
	// Tidy up
	[result unlockFocus];
	return [result autorelease];
}

+ (NSImage *)customPageIconMaskImage
{
	static NSImage *result;
	
	if (!result)
	{
		result = [[NSImage imageNamed:@"pagemask"] retain];
	}
	
	return result;
}

+ (NSImage *)customPageIconCoverImage
{
	static NSImage *result;
	
	if (!result)
	{
		result = [[NSImage imageNamed:@"pageborder"] retain];
	}
	
	return result;
}

#pragma mark -
#pragma mark Custom Icon Generation Queue

- (void)addPageToCustomIconGenerationQueue:(KTPage *)page
{
	// If the page is already in the queue, bump it to the top of the list
	unsigned index = [myCustomIconGenerationQueue indexOfObject:page];
	if (index != NSNotFound)
	{
		[myCustomIconGenerationQueue removeObjectAtIndex:index];
		[myCustomIconGenerationQueue insertObject:page atIndex:0];
	}
	
	// Otherwise add the page to the queue
	else
	{
		[myCustomIconGenerationQueue addObject:page];
		
		// Begin generating if there's space
		if (!myGeneratingCustomIcon)
		{
			[self beginGeneratingCustomIconForPage:page];
		}
	}
}

- (void)beginGeneratingCustomIconForPage:(KTPage *)page
{
	// We only ever generate 1 icon at a time since it's a pretty low priority task
	NSAssert(!myGeneratingCustomIcon, @"Can only generate 1 icon at a time");
	
	// Remove the page from the queue
	[myCustomIconGenerationQueue removeObject:page];
	
	// Detach thread for generation if possible
	NSString *iconSourcePath = [[[page customSiteOutlineIcon] file] currentPath];
	if (iconSourcePath)
	{
		myGeneratingCustomIcon = [page retain];
		
		BOOL mask = NO;
		if (![[self document] displaySmallPageIcons])
		{
			mask = [page shouldMaskCustomSiteOutlinePageIcon:page];
		}
		
		NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
			page, @"page",
			[NSNumber numberWithBool:mask], @"mask",
			iconSourcePath, @"file", nil];
		
		[NSThread detachNewThreadSelector:@selector(threadedGenerateCustomIcon:)
								 toTarget:self
							   withObject:parameters];
	}
}

- (void)didGenerateCustomIcon:(NSImage *)icon forPage:(KTPage *)page
{
	// Remove page from generating list
	[myGeneratingCustomIcon release];	myGeneratingCustomIcon = nil;
	
	// Update the cache
	[myCachedCustomPageIcons setValue:icon forKey:[page uniqueID]];
	
	// Refresh Site Outline for new icon
	[self reloadPage:page reloadChildren:NO];
	
	// Generate the first icon in queue
	if ([myCustomIconGenerationQueue count] > 0)
	{
		[self beginGeneratingCustomIconForPage:[myCustomIconGenerationQueue firstObject]];
	}
}

- (void)threadedGenerateCustomIconForPage:(KTPage *)page fromFile:(NSString *)path mask:(BOOL)mask
{
	// Create the icon
	NSImage *result;
	unsigned iconSize = [self maximumIconSize];
	
	if (mask)
	{
		result = [[[self class] maskedIconOfFile:path size:iconSize] retain];
	}
	else
	{
		result = [[NSImage alloc] initWithContentsOfFile:path ofMaximumSize:iconSize];
	}
	
	// Notify the main thread that we're done
	[self performSelectorOnMainThreadAndReturnResult:@selector(didGenerateCustomIcon:forPage:)
										  withObject:result withObject:page];
	
	// Tidy up
	[result release];
}

- (void)threadedGenerateCustomIcon:(NSDictionary *)parameters
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self threadedGenerateCustomIconForPage:[parameters objectForKey:@"page"]
								   fromFile:[parameters objectForKey:@"file"]
									   mask:[parameters boolForKey:@"mask"]];
	
	[pool release];
}

#pragma mark -
#pragma mark Support

/*	Either 32 / 16 pixels depending on the users displaySmallPageIcons setting.
 *	Then multiply by the scale factor.
 */
- (unsigned)maximumIconSize
{
	// Get the scale factor if needed
	static float sScaleFactor;
	if (!sScaleFactor)
	{
		sScaleFactor = [[[self siteOutline] window] userSpaceScaleFactor];
	}
	
	// Figure out the size
	if ([[self document] displaySmallPageIcons])
	{
		return sScaleFactor * 16.0;
	}
	else
	{
		return sScaleFactor * 32.0;
	}
}

@end
