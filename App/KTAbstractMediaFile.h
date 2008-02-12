//
//  KTAbstractMediaFile.h
//  Marvel
//
//  Created by Mike on 05/11/2007.
//  Copyright 2007 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class KTMediaManager, KTPage, KTMediaFileUpload;


@interface KTAbstractMediaFile : NSManagedObject
{
}

+ (NSString *)entityName;

// Accessors
- (KTMediaManager *)mediaManager;
- (NSString *)fileType;

// Paths
- (NSString *)currentPath;	// Where the file is currently being stored.
- (KTMediaFileUpload *)defaultUpload;

+ (float)scaleFactorOfSize:(NSSize)sourceSize toFitSize:(NSSize)desiredSize;
+ (NSSize)sizeOfSize:(NSSize)sourceSize toFitSize:(NSSize)desiredSize;

// all return NSZeroSize if not an image
- (NSSize)dimensions;
- (float)imageScaleFactorToFitSize:(NSSize)desiredSize;
- (NSSize)imageSizeToFitSize:(NSSize)desiredSize;
- (float)imageScaleFactorToFitWidth:(float)width;
- (float)imageScaleFactorToFitHeight:(float)height;

// Error Recovery
- (NSString *)bestExistingThumbnail;

@end
