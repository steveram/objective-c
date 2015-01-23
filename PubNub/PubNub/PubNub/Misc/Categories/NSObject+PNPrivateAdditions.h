//
//  NSObject+PNPrivateAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNDate;


#pragma mark - Category methods declaration

@interface NSObject (PNPrivateAdditions)


#pragma mark - Instance methods

#pragma mark - Data synchronization methods

/**
 @brief      Store remote object modification date.
 
 @discussion This method is useful for data received for remote data object from \b PubNub cloud.
 
 @param modificationTimeToken Reference on time token represent last moment when receiver has been
                              changed in \b PubNub cloud.
 
 @since <#version number#>
 */
- (void)pn_setModificationDate:(NSNumber *)modificationTimeToken;

/**
 @brief      Store reference on index which has been assigned to the entry by \b PubNub cloud 
             service.
 
 @discussion To represent and sort items on server \b PubNub cloud use it's own index for sorting.
 
 @since <#version number#>
 */
- (void)pn_setIndex:(NSString *)index;

/**
 @brief Use provided data to merge it the the one which maybe already stored in receiver
        instance.

 @discussion Using provided path receiver will be able to find out where it should apply new data
             and if required create all entries following provided key-path.
             Basic task of this method is to find at specified location object into which data will
             be merged using \c -pn_mergeData: method.

 @param data                Reference on data which should be merged with data at specified
                            \c dataLocationKeyPath
 @param dataLocationKeyPath Reference on target data location key-path where provided data should
                            be stored. In case if \c nil provided, data will be stored in object
                            root node.

 @warning This method should be called always on root node of \b PNObject data.

 @since <#version number#>
 */
- (void)pn_mergeData:(id)data at:(NSString *)dataLocationKeyPath;

/**
 @brief Use provided data to merge it the the one which maybe already stored in receiver 
        instance.
 
 @discussion Using provided path receiver will be able to find out where it should apply new data
             and if required create all entries following provided key-path.
 
 @param data                Reference on data which should be merged with data at specified 
                            \c dataLocationKeyPath
 
 @since <#version number#>
 */
- (void)pn_mergeData:(id)data;


/**
 @brief Allow to compile \b PubNub cloud representation of the object into native Objective-C
        objects.
 
 @param pubNubCloudData Reference on data which should be merged with data at specified
                        \c dataLocationKeyPath
 
 @since <#version number#>
 */
- (void)pn_mergeRemoteObjectData:(NSDictionary *)pubNubCloudData;

/**
 @brief Use provided data location key-path to try remove data stored in cache.
 
 @param dataLocationKeyPath Key-path along which client should follow and delete data.
 
 @note If along key-path after rremoval will be empty objects (dictionary with zero values or 
       empty array entry) they wil be removed.
 
 @since <#version number#>
 */
- (void)pn_removeRemoteObjectDataAtPath:(NSString *)dataLocationKeyPath;


#pragma mark - GCD helper methods

/**
 Retrieve reference on private queue.
 
 @return Private queue or \c NULL if it hasn't been set yet.
 */
- (dispatch_queue_t)pn_privateQueue;

/**
 @brief Configure private queue which will be owned by object on which it configured.
 
 @discussion At configuration, object is able to retain created queue, but destruction should be 
 assisted from outside (because category created on base class which won't allow to reload -dealloc
 method).
 
 @param identifier Identifier of the owner which will be append as prefix to unique queue 
                   identifier.
 @param priority   Priority of the queue, which should be set as target for this private queue.
 
 @since 3.7.3
 */
- (void)pn_setupPrivateSerialQueueWithIdentifier:(NSString *)identifier
                                     andPriority:(dispatch_queue_priority_t)priority;

/**
 Terminate and release private dispatch queue.
 */
- (void)pn_destroyPrivateDispatchQueue;

/**
 Dispatch specified block asynchronously on private queue.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchBlock:(dispatch_block_t)block;

/**
 Dispatch specified block on queue asynchronously.

 @warning Assertion will fire in case if private queue not specified earlier.

 @param queue
 Reference on queue which should be used for block dispatching.

 @param block
 Code block which should be dispatched.
 */
- (void)pn_dispatchOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

/**
 Create assertion which will fire in case if code is running on non-private queue.
 */
- (void)pn_scheduleOnPrivateQueueAssert;

/**
 @brief Allow to disable assert for the time when code should be called outside of queue.
 
 @discussion This method mostly used in cases where there is not much time for GCD async operation 
 completion, but queue dedicated methods should be called.
 This method doesn't have backward functionality and permanently disable requirement.
 
 @since 3.7.3
 */
- (void)pn_ignorePrivateQueueRequirement;

#pragma mark -


@end
