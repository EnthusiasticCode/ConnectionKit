//
//  SVAuxiliaryPageletText.h
//  Sandvox
//
//  Created by Mike on 04/03/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SVRichText.h"

@class SVGraphic;

@interface SVAuxiliaryPageletText :  SVRichText  

@property(nonatomic, retain, readonly) SVGraphic *pagelet;
@property(nonatomic, retain) NSNumber *hidden; // BOOL, mandatory

@end



