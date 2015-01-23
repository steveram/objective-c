/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNSynchronizationChannel.h"


#pragma mark Private interface declaration

@interface PNSynchronizationChannel ()


#pragma mark - Properties

/**
@brief Stores reference on object identifier for which this synchronization channel has been
       created or not.

@since <#version number#>
*/
@property (nonatomic, copy) NSString *identifier;

/**
 @brief Stores reference on remote object data location which client would like to synchronize
        with local copy.
 
 @since <#version number#>
 */
@property (nonatomic, copy) NSString *dataLocation;


#pragma mark - Class methods

/**
 @brief Construct channel for real-time events observation on local object copy change from
        cloud.

 @param objectIdentifier Reference on identifier which represent remote object in \b PubNub cloud.
 @param location         Reference on sub-path inside remote object (this allow to observe
                         changes only on piece of remote object).

 @return Channel which will represent remote object data feed for synchronization events.

 @since <#version number#>
 */
+ (instancetype)channelForObject:(NSString *)objectIdentifier dataAtLocation:(NSString *)location;

/**
 @brief      Construct all channels which is required to receive all events while \b PubNub 
             client synchronized with remote object from \b PubNub cloud.
 
 @discussion Using this method will be build channels for object and data location itself as well
             as for data location children nodes and data transaction observation.
 
 @param objectIdentifier Reference on identifier which represent remote object in \b PubNub cloud.
 @param locations        Reference on sub-paths inside of remote object (this allow to observe
                         changes only for specified pieces of remote object).
 
 @return Required set of channels for synchronization and synchronization transactions
         observation.
 
 @since <#version number#>
 */
+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataAtLocations:(NSArray *)locations;

/**
 @brief      Construct all channels which is required to receive all events while \b PubNub 
             client synchronized with remote object from \b PubNub cloud.
 
 @discussion Using this method will be build channels for object and data location itself as well
             as for data location children nodes and data transaction observation.
 
 @param objectIdentifier             Reference on identifier which represent remote object in 
                                     \b PubNub cloud.
 @param locations                    Reference on sub-paths inside of remote object (this allow 
                                     to observe  changes only for specified pieces of remote 
                                     object).
 @param shouldCreatedTransactionFeed Whether helper method should create channel used to observe
                                     transactions or not.
 
 @return Required set of channels for synchronization and synchronization transactions
         observation.
 
 @since <#version number#>
 */
+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataAtLocations:(NSArray *)locations
          includingTransaction:(BOOL)shouldCreatedTransactionFeed;

/**
 @brief Check whether specified name correspond to one of data synchronization channels or not.
 
 @param channelName Name of the channels against which check should be done.
 
 @return \c YES in case if this channel is used for Data Synchronization feature.
 
 @since <#version number#>
 */
+ (BOOL)isObjectSynchronizationChannel:(NSString *)channelName;

/**
 @brief Extract remote object identifier from provided channel name.

 @param channelName Name of the channel which should be using during extraction process.

 @return Remote object identifier.

 @since <#version number#>
 */
+ (NSString *)objectIdentifierFrom:(NSString *)channelName;

/**
 @brief Try to use passed object identifier to find data location path in it.

 @param channelName Name of the channel which should be using during extraction process.

 @return \c YES in case if this channel is used for Data Synchronization feature.

 @since <#version number#>
 */
+ (NSString *)objectModificationLocationFrom:(NSString *)channelName;

/**
 @brief Filter provided list of channels and return only channels which represent base remote
        data object synchronization channel (root level w/o wild cards).
 
 @param channels List of channels which should be filtered.
 
 @return Empty array in case if provided list doesn't have any signs of remote object data 
         synchronization feed channels.
 
 @since <#version number#>
 */
+ (NSArray *)baseSynchronizationChannelsFromList:(NSArray *)channels;

#pragma mark -


@end
