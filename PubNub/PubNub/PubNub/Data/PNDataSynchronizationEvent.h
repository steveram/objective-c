//
//  PNDataSynchronizationEvent.h
//  PubNub
//
//  Created by Sergey Mamontov on 1/10/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Types & Structures

typedef NS_OPTIONS(NSUInteger, PNDataSynchronizationEventType) {

    /**
     @brief Represent event from \b PubNub service which tell that piece of data has been updated
            and should be applied on local cache.

     @since <#version number#>
     */
    PNDataUpdateEvent,

    /**
     @brief Represent event from \b PubNub service which tell that piece of data has been replaced
            with new one.

     @since <#version number#>
     */
    PNDataReplaceEvent,

    /**
     @brief Represent event from \b PubNub service which tell that piece of data has been removed.

     @since <#version number#>
     */
    PNDataDeleteEvent,

    /**
     @brief Represent event from \b PubNub service which tell that all change events from bulk has
            been received and should be applied on local cache.

     @since <#version number#>
     */
    PNDataTransactionCompleteEvent
};



#pragma mark - Public interface declaration

@interface PNDataSynchronizationEvent : NSObject


#pragma mark - Properties

/**
 @brief      Stores reference on actual data synchronization event.

 @discussion Depending on the type, \b PubNub's synchronization manager will perform corresponding
             actions on locally cached data.

 @since <#version number#>
 */
@property (nonatomic, readonly, assign) PNDataSynchronizationEventType type;

/**
 @brief      Reference on object identifier for which modification has been applied in \b PubNub
             cloud.

 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *objectIdentifier;

/**
 @brief      Stores reference on changes transaction identifier.

 @discussion All changes on remote data object distributed to observers via special set of channels.
             Most of the time changes done in bulk and set of synchronization events followed by
             special transaction complete event to let clients know when they can commit received
             changes.

 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *moidificationTransactionIdentifier;

/**
 @brief      In addition to modifications location there is location which represent relative object
             to the one, which has been changed.

 @discussion In case if something has been added to the list or new entry to the object, this value
             will store location key-path to list root or object.

 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *relativeLocation;

/**
 @brief      Every data updates happens on particular data location.

 @discussion Changes can be done on some piece od remote object data or for whole object's data by
             applying changes on the root node.

 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *modificationLocation;

/**
 @brief      Reference on value modification date.

 @discussion This value mostly used by \b PubNub synchronization manager to order changes before
             merging them into local cache.

 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *modificationTimeToken;

/**
 @brief      Reference on actual data which has been used for modification.

 @discussion This value is \c nil for \c PNDataDeleteEvent and \c PNDataTransactionCompleteEvent
             synchronization event types.

 @since <#version number#>
 */
@property (nonatomic, readonly, strong) id data;

#pragma mark -


@end
