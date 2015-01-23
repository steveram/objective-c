#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNDate;


/**
 @brief Base Objective-C class extension.
 
 @discussion This extension applied on base class so it will be possible to share some \b PubNub
             specific functionality for developers.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface NSObject (PNAdditions)


#pragma mark - Instance methods

/**
 @brief      Receive object's modification date.
 
 @discussion This method is useful for data received for remote data object from \b PubNub cloud.
 
 @return \c nil in case if this object arrived not from \b PubNub cloud or represent collection
         type instance.
 
 @since <#version number#>
 */
- (NSNumber *)pn_modificationDate;

/**
 @brief      Receive \b PubNub defined index for object which has been received from list.
 
 @discussion Remote object in \b PubNub cloud is able to store lists (locally represented by 
             \a NSArray) and this method allow to retrieve index of concrete entry but in context
             of \b PubNub cloud.
             Received index also can be used as part of modification path.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Reference on list received from PNObject (after synchronization) or from PNObjectInformation
 // in case if data has been requested manually.
 NSArray *entries = ....;
 NSString *entryPubNubIndex = [entries[0] pn_index]; // Will assign something like this: -!14169947586481522
 @endcode
 
 @return Array entry index from \b PubNub cloud context (NSArray index is 0..N and \b PubNub 
         indices like this -!14169947586481522)
 
 @since <#version number#>
 */
- (NSString *)pn_index;

/**
 @brief      Retrieve value stored at specified key-path.
 
 @discussion This is universal method which can be called on both array and dictionary. Key-path
             may contain \b PubNub entry index as it's part and this method will find 
             corresponding entry in array and if required will follow key-path further.
 
 @param keyPath Data location key-path from which receiver should try to pull out data.
 
 @return \c nil in case if receiver doesn't have value for provided key-path.
 
 @since <#version number#>
 */
- (id)pn_objectAtKeyPath:(NSString *)keyPath;

#pragma mark -

@end
