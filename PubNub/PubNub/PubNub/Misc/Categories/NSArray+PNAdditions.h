//
//  NSArray+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import <Foundation/Foundation.h>


#pragma mark Category methods declaration

@interface NSArray (PNAdditions)


#pragma mark - Instance methods

/**
 @brief Search for object with specified \b PubNub cloud list entry index.

 @param pnIndex \b PubNub entry index which should be found in list.

 @return \c nil in case if receiver array doesn't have entry with specified \c pnIndex.

 @since <#version number#>
 */
- (id)pn_objectAtIndex:(NSString *)pnIndex;

#pragma mark -


@end
