//
//  SVMigrationManager.m
//  Sandvox
//
//  Created by Mike on 14/02/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "SVMigrationManager.h"


@implementation SVMigrationManager

- (NSFetchRequest *)pagesFetchRequest;
{
    // The default request generated by Core Data ignores sub-entites, meaning the home page doesn't get migrated. So, I wrote this custom method that builds a less picky predicate.
    
    NSFetchRequest *result = [[[NSFetchRequest alloc] init] autorelease];
    [result setEntity:[self sourceEntityForEntityMapping:[self currentEntityMapping]]];
    
    
    return result;
}

@end
