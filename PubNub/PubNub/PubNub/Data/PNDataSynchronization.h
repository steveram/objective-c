#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNDataSynchronizationTask, PNDataSynchronizationEvent, PNObjectInformation, PNObject, PNError;


/**
 @brief      Remote data object synchronization manager.
 
 @discussion This instance would manage local copies of remote data objects stored in \b PubNub
             cloud. Also it helps to manage list of data feeds channel which should be used to
             receive updates from cloud.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface PNDataSynchronization : NSObject


#pragma mark - Data feeds helper methods

/**
 @brief      Prepare manager for object synchronization process.
 
 @discussion Provided object information will be placed into special local cache and allow 
             sequental updates from multi-paged remote object data.
             At the end of synchronization process manager will merge received data into local
             copy of remote object (\b PNObject) or create new one. Merge will be done basing on
             \b replace algorithm.
             Manager will use this opportunity to calculate set of data synchronization feed
             objects on which client should subscribe or unsubscribe from.
 
 @param objectInformation Reference on temporary instance which describes locally remote object
                          from \b PubNub cloud and will be used for temoporary storage of data
                          received from \b PubNub cloud.
 @param completionBlock   Block which is called at the end of preparation to let know called that
                          everything has been prepared. Pass two arguments: 
                          \c relevantDataFeedObjects - list of data synchronization channels on 
                          which client should subscribe; \c irrelevantDataFeedObjects - list of 
                          channels from which client should unsubscribe.
 
 @note Object is able to perform synchronization only for one \c objectInformation instance at 
       once.
 
 @since <#version number#>
 */
- (void)prepareForSynchronizationOf:(PNObjectInformation *)objectInformation
                          withBlock:(void (^)(NSArray *relevantDataFeedObjects,
                                              NSArray *irrelevantDataFeedObjects))completionBlock;

/**
 @brief      Prepare manager for object synchronization termination.
 
 @discussion Provided object information will be placed into special local cache and allow to
             track synchronization termination process.
             At the end of synchronization termination process manager will try to remove 
             returndant data from remote object's local cache.
             Manager will use this opportunity to calculate set of data synchronization feed
             objects on which client should subscribe or unsubscribe from.
 
 @param objectInformation Reference on temporary instance which describes locally remote object
                          from \b PubNub cloud.
 @param completionBlock   Block which is called at the end of preparation to let know called that
                          everything has been prepared. Pass two arguments: 
                          \c relevantDataFeedObjects - list of data synchronization channels on 
                          which client should subscribe; \c irrelevantDataFeedObjects - list of 
                          channels from which client should unsubscribe.
 
 @note Object is able to perform synchronization only for one \c objectInformation instance at 
       once.
 
 @since <#version number#>
 */
- (void)prepareForSynchronizationStopFor:(PNObjectInformation *)objectInformation
                               withBlock:(void (^)(NSArray *relevantDataFeedObjects,
                                                   NSArray *irrelevantDataFeedObjects))completionBlock;

/**
 @brief Configure synchronization manager to handle further fetch events on remote data object.
 
 @param objectIdentifier Reference on identifier under which data object stored inside of
                         \b PubNub cloud.
 @param completionBlock  Block which is called at the end of prepraration process to inform that
                         \b PubNub client may proceed,
 
 @since <#version number#>
 */
- (void)prepareForDataFetchFor:(NSString *)objectIdentifier withBlock:(dispatch_block_t)completionBlock;

/**
 @brief Check whether there is active synchronization tasks at this moment or not.
 
 @param checkCompletionBlock Block which is called at the end of check process and pass only one
                             argument which tell whether there is active synchronization process
                             or not.
 
 @since <#version number#>
 */
- (void)hasActiveSynchronizationTasks:(void (^)(BOOL hasActiveTask))checkCompletionBlock;

/**
 @brief Using local cache check whether \b PubNub client currently performs synchronization tasks
        for object with specified identifier.
 
 @param task             Reference on active task with all information about current progress and
                         reference on instance which temporary represent remote object in local
                         cache.
 @param completionBlock  Block which is called at the end of check process. Block pass three
                         arguments: \c objectInformation - reference on instance which temporary
                         represent remote object during synchronization process; 
                         \c hasActiveTask - allow to find out whether there is syncrhonization 
                         task or not; \c isSynchronizationStart - whether task has been created 
                         for synchronization launch.
 
 @since <#version number#>
 */
- (void)hasActiveSynchronizationTaskFor:(NSString *)objectIdentifier
                              withBlock:(void(^)(PNDataSynchronizationTask *task,
                                                 BOOL hasActiveTask,
                                                 BOOL isSynchronizationStart))completionBlock;

/**
 @brief      Handle synchronization start event on set of data synchronization feeds.
 
 @discussion Handle and commit subscription event on synchronization task for each of remote
             object identifiers which can be passed in \c synchronizationDataFeedObjects .
 
 @param synchronizationDataFeedObjects List of data feed synchronization objects for which
                                       \b PubNub completed one of steps (subscribe or unsubscribe
                                       to/from set of data feed synchronization objects).
 @param completionBlock                Handling completion block is called when all preparations
                                       for next step is done and pass only one argument
                                       \c synchronizationTasks which stores list of tasks for
                                       each remote data object identifier which has been passed 
                                       in \c synchronizationDataFeedObjects .
 
 @since <#version number#>
 */
- (void)handleSynchronizationOn:(NSArray *)synchronizationDataFeedObjects
                      withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock;

/**
 @brief      Handle synchronization stop event on set of data synchronization feeds.
 
 @discussion Handle and commit unsubscription event on synchronization task for each of remote
             object identifiers which can be passed in \c synchronizationDataFeedObjects .
 
 @param synchronizationDataFeedObjects List of data feed synchronization objects for which
                                       \b PubNub completed one of steps (subscribe or unsubscribe
                                       to/from set of data feed synchronization objects).
 @param completionBlock                Handling completion block is called when all preparations
                                       for next step is done and pass only one argument
                                       \c synchronizationTasks which stores list of tasks for
                                       each remote data object identifier which has been passed 
                                       in \c synchronizationDataFeedObjects .
 
 @since <#version number#>
 */
- (void)handleSynchronizationStopOn:(NSArray *)synchronizationDataFeedObjects
                          withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock;

/**
 @brief      Handle synchronization error event on set of data synchronization feeds.
 
 @discussion Handle error event on synchronization task for each of remote
             object identifiers which can be passed in \c synchronizationDataFeedObjects .
 
 @param error                          Reference on error which describe what exactly went wrong.
 @param synchronizationDataFeedObjects List of data feed synchronization objects for which
                                       \b PubNub completed one of steps (subscribe or unsubscribe
                                       to/from set of data feed synchronization objects).
 @param completionBlock                Handling completion block is called when all preparations
                                       for next step is done and pass only one argument
                                       \c synchronizationTasks which stores list of tasks for
                                       each remote data object identifier which has been passed 
                                       in \c synchronizationDataFeedObjects .
 
 @since <#version number#>
 */
- (void)handleSynchronizationError:(PNError *)error onObjects:(NSArray *)synchronizationDataFeedObjects
                         withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock;

/**
 @brief Check whether there is active fetch request for specified remote object.
 
 @param objectIdentifier Remote object identifier for which check should be performed.
 @param completionBlock  Check completion block which pass only one argument 
                         \c activeObjectInformation refer on object used for fetch cache.
 
 @since <#version number#>
 */
- (void)hasActiveFetchFor:(NSString *)objectIdentifier
                witbBlock:(void (^)(PNObjectInformation *activeObjectInformation))completionBlock;

/**
 @brief Handle data fetch completion for piece of remote object
 
 @param objectInformation Reference on instance which temporary represent remote data object and
                          contain all required information to complete merging with local cache.
 @param completionBlock   Processing completion block which pass only one argument \c task which
                          is reference on active synchronization task.
 
 @since <#version number#>
 */
- (void)handleDataFetchCompletionFor:(PNObjectInformation *)objectInformation
                            andBlock:(void (^)(PNDataSynchronizationTask *task))completionBlock;

/**
 @brief Handle portion of data fetch completion for piece of remote object
 
 @param objectInformation Reference on instance which temporary represent remote data object and
                          contain all required information to complete merging with local cache.
 @param completionBlock   Processing completion block which pass only one argument \c task which
                          is reference on active synchronization task.
 
 @since <#version number#>
 */
- (void)handlePartialDataFetchCompletionFor:(PNObjectInformation *)objectInformation
                                   andBlock:(void (^)(PNDataSynchronizationTask *task))completionBlock;

/**
 @brief Handle data fetch completion for piece of remote object
 
 @param objectInformation Reference on instance which temporary represent remote data object and
                          contain all required information to complete merging with local cache.
 @param error             Reference on error which describe what exactly went wrong.
 @param completionBlock   Processing completion.
 
 @since <#version number#>
 */
- (void)handleDataFetchFor:(PNObjectInformation *)objectInformation failWithError:(PNError *)error
                  andBlock:(dispatch_block_t)completionBlock;

/**
 @brief Handle and process synchronization event.

 @param event             Reference on data synchronization event instance which has all information
                          about when this change has been done.
 @param completionBlock   Handler completion block which is called when event has been stored or
                          data merge process completed. Block pass three arguments: \c object -
                          reference on object for which data has been modified; \c locations - list
                          of locations on which object data has been modified;
                          \c modificationCompleted - whether this was last event packet which ask
                          manager to commit all changes into the object.

 @since <#version number#>
 */
- (void)handleSynchronizationEvent:(PNDataSynchronizationEvent *)event
                         withBlock:(void(^)(PNObject *object, NSArray *locations,
                                    BOOL modificationCompleted))completionBlock;


#pragma mark - Misc methods

/**
 @brief Clean up local cache from all objects and synchronization events.
 
 @since <#version number#>
 */
- (void)purgeLocalCache;

#pragma mark -


@end
