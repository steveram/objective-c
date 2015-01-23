//
//  NSDictionary+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface NSDictionary (PNAdditions)


#pragma mark - Class methods

/**
 @brief Filter provided list of key-paths to find those who represent top most levels (more 
        general).
 
 @discussion If list contains for example \c a.b.c and \c a.b.c.foo this method will remove
             second key-path and return list with \c a.b.c in it.
 
 @param keyPaths List of key-paths against which filter should be launched.
 
 @return List of key-paths with top most versions.
 
 @since <#version number#>
 */
+ (NSArray *)pn_topLevelKeysFromList:(NSArray *)keyPaths;


#pragma mark - Instance methods

/**
 Validate provided dictionary and check whether values are: int, float string.

 @return \c YES if provided dictionary conforms to the requirements.
 */
- (BOOL)pn_isValidState;

#pragma mark -


@end
