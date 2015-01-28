/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PubNub+DataSynchronization.h"
#import "PNSynchronizationChannel+Protected.h"
#import "PNObjectInformation+Protected.h"
#import "NSObject+PNPrivateAdditions.h"
#import "NSArray+PNPrivateAdditions.h"
#import "PNDataSynchronizationEvent.h"
#import "PNDataSynchronizationTask.h"
#import "PubNub+Subscription.h"
#import "NSArray+PNAdditions.h"
#import "PNMessagingChannel.h"
#import "PNServiceChannel.h"
#import "PNRequestsImport.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNStructures.h"
#import "PNHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark Static

/**
 @brief Stores reference on maximum data key-path location components count.
 
 @since <#version number#>
 */
static NSUInteger const kPNMaximumSegmentsCount = 32;

/**
 @brief Stores reference on maximum length of kee-path segment.
 
 @since <#version number#>
 */
static NSUInteger const kPNMaximumSegmentLength = 64;


#pragma mark - Category private interface declaration

@interface PubNub (PrivateDataSynchronization)


#pragma mark - Instance methods

#pragma mark - Synchronization methods

/**
 @brief Synchronize local copy of the object with data stored in \b PubNub cloud under specified
        location.

 @param objectIdentifier        Reference on remote object identifier which should be pulled to 
                                the local copy.
 @param locations               Key-paths to portions of data which should be in sync with 
                                \b PubNub cloud object. In case if \c nil or empty array is 
                                passed, whole object from \b PubNub cloud will be synchronized
                                with local object copy.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client during object
                                synchronization process change. The block takes three arguments:
                                \c object - reference on \b PNObject which is used to represent 
                                object from \b PubNub cloud locally; \c location - key-path to 
                                the particular piece of data for which synchronization has been
                                started; \c error - describes what exactly went wrong (check 
                                error code and compare it with \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)synchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations
         reschedulingMethodCall:(BOOL)isMethodCallRescheduled
        completionHandlingBlock:(PNRemoteObjectSynchronizationStartHandlerBlock)handlerBlock;


/**
 @brief Postpone synchronize local copy of the object with data stored in \b PubNub cloud under 
        specified location.

 @param objectIdentifier        Reference on remote object identifier which should be pulled to 
                                the local copy.
 @param locations               Key-paths to portions of data which should be in sync with 
                                \b PubNub cloud object. In case if \c nil or empty array is 
                                passed, whole object from \b PubNub cloud will be synchronized
                                with local object copy.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client during object
                                synchronization process change. The block takes three arguments:
                                \c object - reference on \b PNObject which is used to represent 
                                object from \b PubNub cloud locally; \c location - key-path to 
                                the particular piece of data for which synchronization has been
                                started; \c error - describes what exactly went wrong (check 
                                error code and compare it with \b PNErrorCodes ).
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @since <#version number#>
 */
- (void)postponeSynchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations
                 reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                completionHandlingBlock:(PNRemoteObjectSynchronizationStartHandlerBlock)handlerBlock;

/**
 @brief Stop remote object synchronization with local copy under specified data location key-paths.
 
 @param objectIdentifier        Reference on remote object identifier for which client should 
                                stop synchronization process.
 @param locations               Key-paths to portions of data for which client should stop sync 
                                with \b PubNub cloud object. In case if \c nil or empty array is 
                                passed, client will try to stop synchronization for whole object.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client during object
                                synchronization process change. The block takes two arguments:
                                \c objectInformation - contains information about object for
                                which client tried to stop synchronization with local copy and 
                                list of location key-paths if only pieces of remote data object 
                                has been syncrhonized; \c error - describes what exactly went 
                                wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)stopRemoteObjectSynchronization:(NSString *)objectIdentifier
                    withDataAtLocations:(NSArray *)locations
                 reschedulingMethodCall:(BOOL)isMethodCallRescheduled
            withCompletionHandlingBlock:(PNRemoteObjectSynchronizationStopHandlerBlock)handlerBlock;

/**
 @brief Stop remote object synchronization with local copy under specified data location key-paths.
 
 @param objectIdentifier        Reference on remote object identifier for which client should 
                                stop synchronization process.
 @param locations               Key-paths to portions of data for which client should stop sync 
                                with \b PubNub cloud object. In case if \c nil or empty array is 
                                passed, client will try to stop synchronization for whole object.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            The block which will be called by \b PubNub client during object
                                synchronization process change. The block takes two arguments:
                                \c objectInformation - contains information about object for
                                which client tried to stop synchronization with local copy and 
                                list of location key-paths if only pieces of remote data object 
                                has been syncrhonized; \c error - describes what exactly went 
                                wrong (check error code and compare it with \b PNErrorCodes ).
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @since <#version number#>
 */
- (void)postponeRemoteObjectSynchronizationStop:(NSString *)objectIdentifier
                            withDataAtLocations:(NSArray *)locations
                         reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                    withCompletionHandlingBlock:(PNRemoteObjectSynchronizationStopHandlerBlock)handlerBlock;


#pragma mark - Remote data object manipulation methods

/**
 @brief      Fetch remote object's data from \b PubNub cloud.
 
 @param objectIdentifier               Remote data object identifier for which data should be 
                                       retrieved from \b PubNub cloud.
 @param location                       Remote object's data location key-path inside of \b PubNub
                                       cloud. In case if \c nil has been provided, \b PubNub
                                       client will try to fetch all data from \b PubNub cloud for 
                                       remote data object.
 @param snapshotDate                   Date starting from which remote object snapshot should be
                                       fetched.
 @param objectDataNextPageToken        Identifier which is used to fetch next data page for 
                                       object from \b PubNub cloud in case if object too big for
                                       single response.
 @param isMethodCallRescheduled        In case if value set to \c YES it will mean that method 
                                       call has been rescheduled and probably there is no handler
                                       block which client should use for observation notification.
 @param handlerBlock                   The block which will be called during remote object data 
                                       fetch process state change. The block takes two arguments:
                                       \c objectInformation - contains information about object
                                       for which client tried to fetch data from \b PubNub cloud 
                                       and data location key-path if only pieces of remote data 
                                       object has been requested; \c error - describes what 
                                       exactly went wrong (check error code and compare it with 
                                       \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)fetchRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                 snapshotDate:(NSString *)snapshotDate
                nextPageToken:(NSString *)objectDataNextPageToken
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
   andCompletionHandlingBlock:(PNRemoteObjectDataFetchHandlerBlock)handlerBlock;

/**
 @brief Postpone remote object's data fetch from \b PubNub cloud.
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @param objectIdentifier               Remote data object identifier for which data should be 
                                       retrieved from \b PubNub cloud.
 @param location                       Remote object's data location key-path inside of \b PubNub
                                       cloud. In case if \c nil has been provided, \b PubNub
                                       client will try to fetch all data from \b PubNub cloud for 
                                       remote data object.
 @param snapshotDate                   Date starting from which remote object snapshot should be
                                       fetched.
 @param objectDataNextPageToken        Identifier which is used to fetch next data page for 
                                       object from \b PubNub cloud in case if object too big for
                                       single response.
 @param isMethodCallRescheduled        In case if value set to \c YES it will mean that method 
                                       call has been rescheduled and probably there is no handler
                                       block which client should use for observation notification.
 @param handlerBlock                   The block which will be called during remote object data 
                                       fetch process state change. The block takes two arguments:
                                       \c objectInformation - contains information about object
                                       for which client tried to fetch data from \b PubNub cloud 
                                       and data location key-path if only pieces of remote data 
                                       object has been requested; \c error - describes what 
                                       exactly went wrong (check error code and compare it with 
                                       \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)postponeRemoteObjectDataFetch:(NSString *)objectIdentifier
                           atLocation:(NSString *)location snapshotDate:(NSString *)snapshotDate
                        nextPageToken:(NSString *)objectDataNextPageToken
               reschedulingMethodCall:(BOOL)isMethodCallRescheduled
           andCompletionHandlingBlock:(PNRemoteObjectDataFetchHandlerBlock)handlerBlock;

/**
 @brief Push new or replace old values inside of remote object's using specified data location 
        key-path in \b PubNub cloud.
 
 @param data                    Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier        Remote data object identifier for which data should be pushed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to 
                                push data to remote object's root node inside of \b PubNub cloud.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data push process state updates. The
                                block takes two arguments: \c objectInformation - contains 
                                information about object to which client tried to push data in 
                                \b PubNub cloud, data location key-path if data should be pushed
                                to concrete location and data which has been pushed; \c error - 
                                describes what exactly went wrong (check error code and compare 
                                it with \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)             pushData:(id)data toRemoteObject:(NSString *)objectIdentifier
                   atLocation:(NSString *)location
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock;

/**
 @brief Postpone push new or replace old values inside of remote object's using specified data 
        location key-path in \b PubNub cloud.
 
 @param data                    Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier        Remote data object identifier for which data should be pushed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to 
                                push data to remote object's root node inside of \b PubNub cloud.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data push process state updates. The
                                block takes two arguments: \c objectInformation - contains 
                                information about object to which client tried to push data in 
                                \b PubNub cloud, data location key-path if data should be pushed
                                to concrete location and data which has been pushed; \c error - 
                                describes what exactly went wrong (check error code and compare 
                                it with \b PNErrorCodes ).
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @since <#version number#>
 */
- (void)     postponeDataPush:(id)data toRemoteObject:(NSString *)objectIdentifier
                   atLocation:(NSString *)location
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock;


/**
 @brief Push new objects to list inside of remote object using specified data location key-path 
        in \b PubNub cloud.
 
 @param data                    Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier        Remote data object identifier for which data should be pushed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to
                                push data to remote object's root node inside of \b PubNub cloud.
 @param entriesSortingKey       Allow to manage lexigraphical sorting mechanism by specifying 
                                char or word with which will be used during output of sorted 
                                list. Only \b [A-Za-z] can be used. If \c nil is passed, then
                                object(s) will be added to the end of the list.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data push process state updates. The
                                block takes two arguments: \c objectInformation - contains 
                                information about object to which client tried to push data in 
                                \b PubNub cloud, data location key-path if data should be pushed
                                to concrete location and data which has been pushed; \c error - 
                                describes what exactly went wrong (check error code and compare 
                                it with \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)         pushObjects:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
                  atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey
      reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  andCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock;


/**
 @brief Postpone new objects push to list inside of remote object using specified data location
        key-path in \b PubNub cloud.
 
 @param data                    Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier        Remote data object identifier for which data should be pushed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to
                                push data to remote object's root node inside of \b PubNub cloud.
 @param entriesSortingKey       Allow to manage lexigraphical sorting mechanism by specifying 
                                char or word with which will be used during output of sorted 
                                list. Only \b [A-Za-z] can be used. If \c nil is passed, then
                                object(s) will be added to the end of the list.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data push process state updates. The
                                block takes two arguments: \c objectInformation - contains 
                                information about object to which client tried to push data in 
                                \b PubNub cloud, data location key-path if data should be pushed
                                to concrete location and data which has been pushed; \c error - 
                                describes what exactly went wrong (check error code and compare 
                                it with \b PNErrorCodes ).
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @since <#version number#>
 */
- (void) postponeObjectsPush:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
                  atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey
      reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  andCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock;

/**
 @brief Completely replace data stored at specified path in \b PubNub cloud object.
 
 @param data                    Data which will be used as replacement to the the value stored at
                                specified location key-path.
 @param objectIdentifier        Remote data object identifier for which data should be pushed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to
                                replace data stored in remote object's root node inside of 
                                \b PubNub cloud.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data replacement process state
                                updates. The block takes two arguments: \c objectInformation -
                                contains information about object for which client tried to 
                                replace piece of data in \b PubNub cloud, data location key-path 
                                if data should be replaced at concrete location and data which 
                                has been used for replacement; \c error - describes what exactly 
                                went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)replaceRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                        witData:(id)data reschedulingMethodCall:(BOOL)isMethodCallRescheduled
    andCompletionHandlingBlock:(PNRemoteObjectDataReplaceHandlerBlock)handlerBlock;

/**
 @brief Postpone data replacement stored at specified path in \b PubNub cloud object.
 
 @param data                    Data which will be used as replacement to the the value stored at
                                specified location key-path.
 @param objectIdentifier        Remote data object identifier for which data should be pushed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to
                                replace data stored in remote object's root node inside of 
                                \b PubNub cloud.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data replacement process state
                                updates. The block takes two arguments: \c objectInformation -
                                contains information about object for which client tried to 
                                replace piece of data in \b PubNub cloud, data location key-path 
                                if data should be replaced at concrete location and data which 
                                has been used for replacement; \c error - describes what exactly 
                                went wrong (check error code and compare it with \b PNErrorCodes ).
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @since <#version number#>
 */
- (void)postponeRemoteObjectDataReplace:(NSString *)objectIdentifier atLocation:(NSString *)location
                                witData:(id)data reschedulingMethodCall:(BOOL)isMethodCallRescheduled
             andCompletionHandlingBlock:(PNRemoteObjectDataReplaceHandlerBlock)handlerBlock;

/**
 @brief Completely remove data stored at specified path in \b PubNub cloud object.
 
 @param objectIdentifier        Remote data object identifier for which data should be removed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to
                                remove all data stored in remote object's root node inside of 
                                \b PubNub cloud.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data removal process state updates.
                                The block takes two arguments: \c objectInformation - contains 
                                information about object for which client tried to remove piece 
                                of data in \b PubNub cloud, data location key-path if data should
                                be removed at concrete location; \c error - describes what
                                exactly went wrong (check error code and compare it with
                                \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)removeRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
        reschedulingMethodCall:(BOOL)isMethodCallRescheduled
   withCompletionHandlingBlock:(PNRemoteObjectDataRemoveHandlerBlock)handlerBlock;

/**
 @brief Postpone comlete data removal stored at specified path in \b PubNub cloud object.
 
 @param objectIdentifier        Remote data object identifier for which data should be removed.
 @param location                Remote object's data location key-path inside of \b PubNub cloud.
                                In case if \c nil has been provided, \b PubNub client will try to
                                remove all data stored in remote object's root node inside of 
                                \b PubNub cloud.
 @param isMethodCallRescheduled In case if value set to \c YES it will mean that method call has 
                                been rescheduled and probably there is no handler block which 
                                client should use for observation notification.
 @param handlerBlock            Callback block called during data removal process state updates.
                                The block takes two arguments: \c objectInformation - contains 
                                information about object for which client tried to remove piece 
                                of data in \b PubNub cloud, data location key-path if data should
                                be removed at concrete location; \c error - describes what
                                exactly went wrong (check error code and compare it with
                                \b PNErrorCodes ).
 
 @note  Postpone can be because of few cases: \b PubNub client is in connecting or initial 
        connection state; another request which has been issued earlier didn't completed yet.
 
 @since <#version number#>
 */
- (void)postponeRemoteObjectDataRemove:(NSString *)objectIdentifier atLocation:(NSString *)location
                reschedulingMethodCall:(BOOL)isMethodCallRescheduled
           withCompletionHandlingBlock:(PNRemoteObjectDataRemoveHandlerBlock)handlerBlock;



#pragma mark - Misc methods

/**
 @brief
 
 @param objectIdentifier <#objectIdentifier description#>
 
 @return <#return value description#>
 
 @since <#version number#>
 */
- (BOOL)isValidRemoteObject:(NSString *)objectIdentifier;

/**
 @brief Validate provided path against existing rules to verify ability to use provided path.
 
 @param location Key-path to portion of data against which check should be done.
 
 @return \c NO in case if specified path doesn't conform to set of requirements.
 
 @since <#version number#>
 */
- (BOOL)isValidDataKeyPath:(NSArray *)locations;

/**
 @brief Check current state of synchronization task and perform corresponding actions.
 
 @param task  Task which should be checked for next step and next values.
 @param error Reference on error which may occure during synchronization steps processing.
 
 @since <#version number#>
 */
- (void)processSynchronizationTask:(PNDataSynchronizationTask *)task withError:(PNError *)error;

/**
 @brief Notify delegate and observers that \b PubNub client successfully completed remote object
        synchronization process.
 
 @param objectInformation Reference on instance which temporary represented remote object 
                          locally.
 @param object            Reference on instance which locally represents remote object 
                          information and state.
 
 @since <#version number#>
 */
- (void)handleSynchronizationCompletionFor:(PNObjectInformation *)objectInformation;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to launch
 synchronization.
 
 @param error Reference on \b PNError instance which stores all information about why request did
 fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectSynchronizationDidFailWithError:(PNError *)error;

/**
 @brief Notify delegate and observers that \b PubNub client successfully completed remote object
        synchronization termination process.
 
 @param objectInformation Reference on instance which temporary represented remote object 
                          locally.
 
 @since <#version number#>
 */
- (void)handleSynchronizationStopCompletionFor:(PNObjectInformation *)objectInformation;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to stop
        synchronization.
 
 @param error Reference on \b PNError instance which stores all information about why request did
              fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectSynchronizationStopDidFailWithError:(PNError *)error;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to fetch
        remote object data from \b PubNub cloud.
 
 @param error Reference on \b PNError instance which stores all information about why request did
              fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectDataFetchDidFailWithError:(PNError *)error;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to fetch
        next portion of remote object's data from \b PubNub cloud.
 
 @param error Reference on \b PNError instance which stores all information about why request did
              fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectNextDataPortionFetchDidFailWithError:(PNError *)error;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to push
 data to remote object data in \b PubNub cloud.
 
 @param error Reference on \b PNError instance which stores all information about why request did
 fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectDataPushDidFailWithError:(PNError *)error;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to push
        list to remote object data in \b PubNub cloud.
 
 @param error Reference on \b PNError instance which stores all information about why request did
              fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectListPushDidFailWithError:(PNError *)error;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to replace
        data in remote object data.
 
 @param error Reference on \b PNError instance which stores all information about why request did
              fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectDataReplaceDidFailWithError:(PNError *)error;

/**
 @brief This method used to notify delegate and observer that \b PubNub client failed to remove
        remote object data data.
 
 @param error Reference on \b PNError instance which stores all information about why request did
              fail.
 
 @since <#version number#>
 */
- (void)notifyDelegateAboutRemoteObjectDataRemoveDidFailWithError:(PNError *)error;

#pragma mark -


@end


#pragma mark - Category interface implementation

@implementation PubNub (DataSynchronization)


#pragma mark - Instance methods

#pragma mark - Synchronization methods

- (NSArray *)synchronizedDataLocationsForRemoteObject:(NSString *)objectIdentifier {
    
    return nil;
}

- (void)synchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations {
    
    [self synchronizeRemoteObject:objectIdentifier withDataAtLocations:locations
       andCompletionHandlingBlock:nil];
}

- (void)synchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations
     andCompletionHandlingBlock:(PNRemoteObjectSynchronizationStartHandlerBlock)handlerBlock {
    
    [self synchronizeRemoteObject:objectIdentifier withDataAtLocations:locations
           reschedulingMethodCall:NO completionHandlingBlock:handlerBlock];
}

- (void)synchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations
         reschedulingMethodCall:(BOOL)isMethodCallRescheduled
        completionHandlingBlock:(PNRemoteObjectSynchronizationStartHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectSynchronizationStartAttempt,
                     objectIdentifier, [PNHelper nilifyIfNotSet:locations], [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsRemoteObjectSynchronizationStartObserver];
            }
            
            PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                              dataLocations:locations
                                                                          snapshotTimeToken:nil];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
            BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
            if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectSynchronizationStart,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsRemoteObjectSynchronizationStartObserverWithCallbackBlock:handlerBlock];
                }
                
                [self.dataSynchronization prepareForSynchronizationOf:objectInformation
                                                            withBlock:^(NSArray *relevantDataFeedObjects,
                                                                        NSArray *irrelevantDataFeedObjects) {
                                                                
                    [self pn_dispatchBlock:^{
                        
                        self.asyncLockingOperationInProgress = NO;
                        if ([irrelevantDataFeedObjects count]) {
                            
                            [self unsubscribeFrom:irrelevantDataFeedObjects];
                        }
                        else {
                            
                            [self subscribeOn:relevantDataFeedObjects];
                        }
                    }];
                }];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectSynchronizationStartImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                NSInteger targetErrorCode = statusCode;
                if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                    
                    if (!isValidKeyPathLocation) {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                    }
                    else {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                    }
                }
                PNError *requestError = [PNError errorWithCode:targetErrorCode];
                requestError.associatedObject = objectInformation;
                
                
                [self notifyDelegateAboutRemoteObjectSynchronizationDidFailWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handlerBlock(nil, objectInformation.dataLocations, requestError);
                    });
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeRemoteObjectSynchronizationStart,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeSynchronizeRemoteObject:objectIdentifier withDataAtLocations:locations
                                  reschedulingMethodCall:isMethodCallRescheduled
                                 completionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeSynchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations
                 reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                completionHandlingBlock:(PNRemoteObjectSynchronizationStartHandlerBlock)handlerBlock {
    
    SEL selector = @selector(synchronizeRemoteObject:withDataAtLocations:reschedulingMethodCall:completionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:objectIdentifier], [PNHelper nilifyIfNotSet:locations],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)stopRemoteObjectSynchronization:(NSString *)objectIdentifier
                    withDataAtLocations:(NSArray *)locations {
    
    [self stopRemoteObjectSynchronization:objectIdentifier withDataAtLocations:locations
              withCompletionHandlingBlock:nil];
}

- (void)stopRemoteObjectSynchronization:(NSString *)objectIdentifier
                    withDataAtLocations:(NSArray *)locations
            withCompletionHandlingBlock:(PNRemoteObjectSynchronizationStopHandlerBlock)handlerBlock {
    
    [self stopRemoteObjectSynchronization:objectIdentifier withDataAtLocations:locations
                   reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)stopRemoteObjectSynchronization:(NSString *)objectIdentifier
                    withDataAtLocations:(NSArray *)locations
                 reschedulingMethodCall:(BOOL)isMethodCallRescheduled
            withCompletionHandlingBlock:(PNRemoteObjectSynchronizationStopHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectSynchronizationStopAttempt,
                     objectIdentifier, [PNHelper nilifyIfNotSet:locations], [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsRemoteObjectSynchronizationStopObserver];
            }
            
            PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                              dataLocations:locations
                                                                          snapshotTimeToken:nil];
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
            BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
            if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectSynchronizationStop,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsRemoteObjectSynchronizationStopObserverWithCallbackBlock:handlerBlock];
                }
                
                [self.dataSynchronization prepareForSynchronizationStopFor:objectInformation
                                                                 withBlock:^(NSArray *relevantDataFeedObjects,
                                                                             NSArray *irrelevantDataFeedObjects) {
                                                                
                    [self pn_dispatchBlock:^{
                        
                        self.asyncLockingOperationInProgress = NO;
                        if ([irrelevantDataFeedObjects count]) {
                            
                            [self unsubscribeFrom:irrelevantDataFeedObjects];
                        }
                        else {
                            
                            [self subscribeOn:relevantDataFeedObjects];
                        }
                    }];
                }];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectSynchronizationStopImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                NSInteger targetErrorCode = statusCode;
                if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                    
                    if (!isValidKeyPathLocation) {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                    }
                    else {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                    }
                }
                PNError *requestError = [PNError errorWithCode:targetErrorCode];
                requestError.associatedObject = objectInformation;
                
                
                [self notifyDelegateAboutRemoteObjectSynchronizationStopDidFailWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handlerBlock(objectInformation, requestError);
                    });
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                       
                       return @[PNLoggerSymbols.api.postponeRemoteObjectSynchronizationStop,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoteObjectSynchronizationStop:objectIdentifier withDataAtLocations:locations
                                          reschedulingMethodCall:isMethodCallRescheduled
                                     withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoteObjectSynchronizationStop:(NSString *)objectIdentifier
                            withDataAtLocations:(NSArray *)locations
                         reschedulingMethodCall:(BOOL)isMethodCallRescheduled
                    withCompletionHandlingBlock:(PNRemoteObjectSynchronizationStopHandlerBlock)handlerBlock {
    
    SEL selector = @selector(stopRemoteObjectSynchronization:withDataAtLocations:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:objectIdentifier], [PNHelper nilifyIfNotSet:locations],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Remote data object manipulation methods

- (void)fetchRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location {
    
    [self fetchRemoteObjectData:objectIdentifier atLocation:location
     andCompletionHandlingBlock:nil];
}

- (void)fetchRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
   andCompletionHandlingBlock:(PNRemoteObjectDataFetchHandlerBlock)handlerBlock {
    
    [self fetchRemoteObjectData:objectIdentifier atLocation:location snapshotDate:nil
                  nextPageToken:nil reschedulingMethodCall:NO
     andCompletionHandlingBlock:handlerBlock];
}

- (void)fetchRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                 snapshotDate:(NSString *)snapshotDate
                nextPageToken:(NSString *)objectDataNextPageToken
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
   andCompletionHandlingBlock:(PNRemoteObjectDataFetchHandlerBlock)handlerBlock {
    
    location = ([location isEqualToString:@"*"] ? nil : location);
    [self pn_dispatchBlock:^{
        
        NSString *statusCode = PNLoggerSymbols.api.remoteObjectDataFetchAttempt;
        if (objectDataNextPageToken) {
            
            statusCode = PNLoggerSymbols.api.remoteObjectDataPortionFetchAttempt;
        }
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[statusCode, [PNHelper nilifyIfNotSet:objectIdentifier],
                     [PNHelper nilifyIfNotSet:location], [PNHelper nilifyIfNotSet:snapshotDate],
                     [PNHelper nilifyIfNotSet:objectDataNextPageToken],
                     [self humanReadableStateFrom:self.state]];
        }];
    
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled && !objectDataNextPageToken) {
                
                [self.observationCenter removeClientAsRemoteObjectDataFetchObserver];
            }
            
            [self.dataSynchronization hasActiveFetchFor:objectIdentifier
                                              witbBlock:^(PNObjectInformation *activeObjectInformation) {
                 
                [self.dataSynchronization prepareForDataFetchFor:objectIdentifier withBlock:^{
                    
                    [self pn_dispatchBlock:^{
                        
                        NSArray *locations = (location ? @[location] : nil);
                        PNObjectInformation *objectInformation = activeObjectInformation;
                        if (!objectInformation) {

                            objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                         dataLocations:locations
                                                                     snapshotTimeToken:nil];
                        }
                        objectInformation.nextDataPageToken = objectDataNextPageToken;
                        
                        // Check whether client is able to send request or not
                        NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
                        BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
                        BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
                        if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                            
                            NSString *statusCode = PNLoggerSymbols.api.remoteObjectDataFetch;
                            if (objectDataNextPageToken) {
                                
                                statusCode = PNLoggerSymbols.api.remoteObjectDataPortionFetch;
                            }
                            
                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                
                                return @[statusCode, [self humanReadableStateFrom:self.state]];
                            }];
                            
                            if (handlerBlock && !isMethodCallRescheduled && !objectDataNextPageToken) {
                                
                                [self.observationCenter addClientAsRemoteObjectDataFetchObserverWithCallBackBlock:handlerBlock];
                            }
                            
                            PNRemoteObjectDataFetchRequest *request = [PNRemoteObjectDataFetchRequest remoteObjectFetchRequestFor:objectInformation];
                            [self sendRequest:request shouldObserveProcessing:YES];
                        }
                        // Looks like client can't send request because of some reasons
                        else {
                            
                            NSString *messageCode = PNLoggerSymbols.api.remoteObjectDataFetchImpossible;
                            if (objectDataNextPageToken) {
                                
                                messageCode = PNLoggerSymbols.api.remoteObjectDataPortionFetchImpossible;
                            }
                            
                            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                                
                                return @[messageCode, [self humanReadableStateFrom:self.state]];
                            }];
                            
                            NSInteger targetErrorCode = statusCode;
                            if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                                
                                if (!isValidKeyPathLocation) {
                                    
                                    targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                                }
                                else {
                                    
                                    targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                                }
                            }
                            PNError *requestError = [PNError errorWithCode:targetErrorCode];
                            requestError.associatedObject = objectInformation;
                            
                            if (![objectInformation.nextDataPageToken length]) {
                                
                                [self notifyDelegateAboutRemoteObjectDataFetchDidFailWithError:requestError];
                            }
                            else {
                                
                                [self notifyDelegateAboutRemoteObjectNextDataPortionFetchDidFailWithError:requestError];
                            }
                            
                            if (handlerBlock && !isMethodCallRescheduled) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    handlerBlock(objectInformation, requestError);
                                });
                            }
                        }
                    }];
                }];
            }];
        }
               postponedExecutionBlock:^{
                   
                   NSString *messageCode = PNLoggerSymbols.api.postponeRemoteObjectDataFetch;
                   if (objectDataNextPageToken) {
                       
                       messageCode = PNLoggerSymbols.api.postponeRemoteObjectDataPortionFetch;
                   }
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                       
                       return @[messageCode, [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoteObjectDataFetch:objectIdentifier atLocation:location
                                          snapshotDate:snapshotDate
                                         nextPageToken:objectDataNextPageToken
                                reschedulingMethodCall:isMethodCallRescheduled
                            andCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoteObjectDataFetch:(NSString *)objectIdentifier
                           atLocation:(NSString *)location snapshotDate:(NSString *)snapshotDate
                        nextPageToken:(NSString *)objectDataNextPageToken
               reschedulingMethodCall:(BOOL)isMethodCallRescheduled
           andCompletionHandlingBlock:(PNRemoteObjectDataFetchHandlerBlock)handlerBlock {
    
    SEL selector = @selector(fetchRemoteObjectData:atLocation:snapshotDate:nextPageToken:reschedulingMethodCall:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:objectIdentifier], [PNHelper nilifyIfNotSet:location],
                             [PNHelper nilifyIfNotSet:snapshotDate], [PNHelper nilifyIfNotSet:objectDataNextPageToken],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)pushData:(id)data toRemoteObject:(NSString *)objectIdentifier
      atLocation:(NSString *)location {
    
    [self pushData:data toRemoteObject:objectIdentifier atLocation:location
withCompletionHandlingBlock:nil];
}

- (void)             pushData:(id)data toRemoteObject:(NSString *)objectIdentifier
                   atLocation:(NSString *)location
  withCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock {
    
    [self pushData:data toRemoteObject:objectIdentifier atLocation:location
reschedulingMethodCall:NO withCompletionHandlingBlock:handlerBlock];
}

- (void)             pushData:(id)data toRemoteObject:(NSString *)objectIdentifier
                   atLocation:(NSString *)location
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPushAttempt, [PNHelper nilifyIfNotSet:objectIdentifier],
                     [PNHelper nilifyIfNotSet:location], [PNHelper nilifyIfNotSet:data],
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsRemoteObjectDataPushObserver];
            }
            
            NSArray *locations = (location ? @[location] : nil);
            PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                              dataLocations:locations
                                                                          snapshotTimeToken:nil];
            objectInformation.data = data;
            
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
            BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
            if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataPush, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsRemoteObjectDataPushObserverWithCallBackBlock:handlerBlock];
                }
                
                PNRemoteObjectDataModificationRequest *request = [PNRemoteObjectDataModificationRequest dataPushRequestFor:objectInformation];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataPushImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                NSInteger targetErrorCode = statusCode;
                if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                    
                    if (!isValidKeyPathLocation) {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                    }
                    else {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                    }
                }
                PNError *requestError = [PNError errorWithCode:targetErrorCode];
                requestError.associatedObject = objectInformation;
                
                [self notifyDelegateAboutRemoteObjectDataPushDidFailWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handlerBlock(objectInformation, requestError);
                    });
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                       
                       return @[PNLoggerSymbols.api.postponeRemoteObjectDataPush,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeDataPush:data toRemoteObject:objectIdentifier atLocation:location
                   reschedulingMethodCall:isMethodCallRescheduled
              withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)     postponeDataPush:(id)data toRemoteObject:(NSString *)objectIdentifier
                   atLocation:(NSString *)location
       reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  withCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock {
    
    SEL selector = @selector(pushData:toRemoteObject:atLocation:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:data], [PNHelper nilifyIfNotSet:objectIdentifier],
                             [PNHelper nilifyIfNotSet:location], @(isMethodCallRescheduled),
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)pushObjects:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
         atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey {
    
    [self pushObjects:entries toRemoteObject:objectIdentifier atLocation:location
       withSortingKey:entriesSortingKey andCompletionHandlingBlock:nil];
}

- (void)         pushObjects:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
                  atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey
  andCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock {
    
    [self pushObjects:entries toRemoteObject:objectIdentifier atLocation:location
       withSortingKey:entriesSortingKey reschedulingMethodCall:NO
andCompletionHandlingBlock:handlerBlock];
}

- (void)         pushObjects:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
                  atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey
      reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  andCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPushToListAttempt, [PNHelper nilifyIfNotSet:objectIdentifier],
                     [PNHelper nilifyIfNotSet:location], [PNHelper nilifyIfNotSet:entries],
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsRemoteObjectDataPushObserver];
            }
            
            NSArray *locations = (location ? @[location] : nil);
            PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                              dataLocations:locations
                                                                          snapshotTimeToken:nil];
            objectInformation.data = entries;
            
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
            BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
            if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataPushToList, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsRemoteObjectDataPushObserverWithCallBackBlock:handlerBlock];
                }
                
                PNRemoteObjectDataModificationRequest *request = [PNRemoteObjectDataModificationRequest dataPushToListRequestFor:objectInformation
                                                                                                                  withSortingKey:entriesSortingKey];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataPushToListImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                NSInteger targetErrorCode = statusCode;
                if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                    
                    if (!isValidKeyPathLocation) {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                    }
                    else {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                    }
                }
                PNError *requestError = [PNError errorWithCode:targetErrorCode];
                requestError.associatedObject = objectInformation;
                
                
                [self notifyDelegateAboutRemoteObjectListPushDidFailWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handlerBlock(objectInformation, requestError);
                    });
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                       
                       return @[PNLoggerSymbols.api.postponeRemoteObjectDataPushToList,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeObjectsPush:entries toRemoteObject:objectIdentifier atLocation:location
                              withSortingKey:entriesSortingKey reschedulingMethodCall:isMethodCallRescheduled
                  andCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void) postponeObjectsPush:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
                  atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey
      reschedulingMethodCall:(BOOL)isMethodCallRescheduled
  andCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock {
    
    SEL selector = @selector(pushObjects:toRemoteObject:atLocation:withSortingKey:reschedulingMethodCall:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:entries], [PNHelper nilifyIfNotSet:objectIdentifier],
                             [PNHelper nilifyIfNotSet:location], [PNHelper nilifyIfNotSet:entriesSortingKey],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)replaceRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                        witData:(id)data {
    
    [self replaceRemoteObjectData:objectIdentifier atLocation:location witData:data
       andCompletionHandlingBlock:nil];
}

- (void)replaceRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                        witData:(id)data
     andCompletionHandlingBlock:(PNRemoteObjectDataReplaceHandlerBlock)handlerBlock {
    
    [self replaceRemoteObjectData:objectIdentifier atLocation:location witData:data
           reschedulingMethodCall:NO andCompletionHandlingBlock:handlerBlock];
}

- (void)replaceRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                        witData:(id)data reschedulingMethodCall:(BOOL)isMethodCallRescheduled
     andCompletionHandlingBlock:(PNRemoteObjectDataReplaceHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataReplaceAttempt, [PNHelper nilifyIfNotSet:objectIdentifier],
                     [PNHelper nilifyIfNotSet:location], [PNHelper nilifyIfNotSet:data],
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsRemoteObjectDataReplaceObserver];
            }
            
            NSArray *locations = (location ? @[location] : nil);
            PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                              dataLocations:locations
                                                                          snapshotTimeToken:nil];
            objectInformation.data = data;
            
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
            BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
            if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataReplace, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsRemoteObjectDataReplaceObserverWithCallBackBlock:handlerBlock];
                }
                
                PNRemoteObjectDataModificationRequest *request = [PNRemoteObjectDataModificationRequest dataReplaceRequestFor:objectInformation];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataReplaceImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                NSInteger targetErrorCode = statusCode;
                if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                    
                    if (!isValidKeyPathLocation) {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                    }
                    else {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                    }
                }
                PNError *requestError = [PNError errorWithCode:targetErrorCode];
                requestError.associatedObject = objectInformation;
                
                
                [self notifyDelegateAboutRemoteObjectDataReplaceDidFailWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handlerBlock(objectInformation, requestError);
                    });
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                       
                       return @[PNLoggerSymbols.api.postponeRemoteObjectDataReplace,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoteObjectDataReplace:objectIdentifier atLocation:location
                                                 witData:data reschedulingMethodCall:isMethodCallRescheduled
                              andCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoteObjectDataReplace:(NSString *)objectIdentifier atLocation:(NSString *)location
                                witData:(id)data reschedulingMethodCall:(BOOL)isMethodCallRescheduled
             andCompletionHandlingBlock:(PNRemoteObjectDataReplaceHandlerBlock)handlerBlock {
    
    SEL selector = @selector(replaceRemoteObjectData:atLocation:witData:reschedulingMethodCall:andCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:objectIdentifier], [PNHelper nilifyIfNotSet:location],
                             [PNHelper nilifyIfNotSet:data], @(isMethodCallRescheduled),
                             [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}

- (void)removeRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location {
    
    [self removeRemoteObjectData:objectIdentifier atLocation:location
     withCompletionHandlingBlock:nil];
}

- (void)removeRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
   withCompletionHandlingBlock:(PNRemoteObjectDataRemoveHandlerBlock)handlerBlock {
    
    [self removeRemoteObjectData:objectIdentifier atLocation:location reschedulingMethodCall:NO
     withCompletionHandlingBlock:handlerBlock];
}

- (void)removeRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
        reschedulingMethodCall:(BOOL)isMethodCallRescheduled
   withCompletionHandlingBlock:(PNRemoteObjectDataRemoveHandlerBlock)handlerBlock {
    
    [self pn_dispatchBlock:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataRemoveAttempt, [PNHelper nilifyIfNotSet:objectIdentifier],
                     [PNHelper nilifyIfNotSet:location], [self humanReadableStateFrom:self.state]];
        }];
        
        [self performAsyncLockingBlock:^{
            
            if (!isMethodCallRescheduled) {
                
                [self.observationCenter removeClientAsRemoteObjectDataRemoveObserver];
            }
            
            NSArray *locations = (location ? @[location] : nil);
            PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:objectIdentifier
                                                                              dataLocations:locations
                                                                          snapshotTimeToken:nil];
            
            
            // Check whether client is able to send request or not
            NSInteger statusCode = [self requestExecutionPossibilityStatusCode];
            BOOL isValidObjectIdentifier = [self isValidRemoteObject:objectIdentifier];
            BOOL isValidKeyPathLocation = [self isValidDataKeyPath:locations];
            if (statusCode == 0 && isValidObjectIdentifier && isValidKeyPathLocation) {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataRemove, [self humanReadableStateFrom:self.state]];
                }];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    [self.observationCenter addClientAsRemoteObjectDataRemoveObserverWithCallBackBlock:handlerBlock];
                }
                
                PNRemoteObjectDataModificationRequest *request = [PNRemoteObjectDataModificationRequest dataRemoveRequestFor:objectInformation];
                [self sendRequest:request shouldObserveProcessing:YES];
            }
            // Looks like client can't send request because of some reasons
            else {
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataRemoveImpossible,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                NSInteger targetErrorCode = statusCode;
                if (!isValidObjectIdentifier || !isValidKeyPathLocation) {
                    
                    if (!isValidKeyPathLocation) {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectNameError;
                    }
                    else {
                        
                        targetErrorCode = kPNIncompatibleRemoteObjectDataLocationError;
                    }
                }
                PNError *requestError = [PNError errorWithCode:targetErrorCode];
                requestError.associatedObject = objectInformation;
                
                
                [self notifyDelegateAboutRemoteObjectDataRemoveDidFailWithError:requestError];
                
                if (handlerBlock && !isMethodCallRescheduled) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        handlerBlock(objectInformation, requestError);
                    });
                }
            }
        }
               postponedExecutionBlock:^{
                   
                   [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray * {
                       
                       return @[PNLoggerSymbols.api.postponeRemoteObjectDataRemove,
                                [self humanReadableStateFrom:self.state]];
                   }];
                   
                   [self postponeRemoteObjectDataRemove:objectIdentifier atLocation:location
                                 reschedulingMethodCall:isMethodCallRescheduled
                            withCompletionHandlingBlock:handlerBlock];
               }];
    }];
}

- (void)postponeRemoteObjectDataRemove:(NSString *)objectIdentifier atLocation:(NSString *)location
                reschedulingMethodCall:(BOOL)isMethodCallRescheduled
           withCompletionHandlingBlock:(PNRemoteObjectDataRemoveHandlerBlock)handlerBlock {
    
    SEL selector = @selector(removeRemoteObjectData:atLocation:reschedulingMethodCall:withCompletionHandlingBlock:);
    id handlerBlockCopy = (handlerBlock ? [handlerBlock copy] : nil);
    [self postponeSelector:selector forObject:self
            withParameters:@[[PNHelper nilifyIfNotSet:objectIdentifier], [PNHelper nilifyIfNotSet:location],
                             @(isMethodCallRescheduled), [PNHelper nilifyIfNotSet:handlerBlockCopy]]
                outOfOrder:isMethodCallRescheduled];
}


#pragma mark - Misc methods

- (BOOL)isValidRemoteObject:(NSString *)objectIdentifier {

    NSCharacterSet *restrictedSymbols = [NSCharacterSet characterSetWithCharactersInString:@".*"];
    BOOL isValidRemoteObject = ([objectIdentifier rangeOfCharacterFromSet:restrictedSymbols].location == NSNotFound);
    if (isValidRemoteObject) {

        isValidRemoteObject = (![objectIdentifier hasPrefix:@"pn_"] && [objectIdentifier length] <= 64);
    }


    return isValidRemoteObject;
}

- (BOOL)isValidDataKeyPath:(NSArray *)locations {

    __block BOOL isValidDataKeyPath = YES;
    @autoreleasepool {

        [locations enumerateObjectsUsingBlock:^(NSString *locationKeyPath, NSUInteger locationKeyPathIdx,
                BOOL *locationKeyPathEnumeratorStop) {

            NSArray *segments = [locationKeyPath componentsSeparatedByString:@"."];
            isValidDataKeyPath = ([segments count] < kPNMaximumSegmentsCount);

            __block NSUInteger maximumSegmentLength = 0;
            NSCharacterSet *restrictedSymbols = [NSCharacterSet characterSetWithCharactersInString:@"!\"#$%&'()*,./<>?[\\]^`{|}~"];
            NSMutableCharacterSet *allowedSymbols = [NSMutableCharacterSet alphanumericCharacterSet];
            [allowedSymbols addCharactersInString:@"-_!"];
            [segments enumerateObjectsUsingBlock:^(NSString *locationKeyPathSegment,
                                                   NSUInteger locationKeyPathSegmentIdx,
                                                   BOOL *locationKeyPathSegmentEnumeratorStop) {
                
                if (isValidDataKeyPath) {
                    
                    isValidDataKeyPath = ([locationKeyPathSegment rangeOfString:@"pn_"].location == NSNotFound);
                }
                
                if (isValidDataKeyPath && [locationKeyPathSegment hasPrefix:@"-"]) {
                    
                    isValidDataKeyPath = [NSArray pn_isEntryIndexString:locationKeyPathSegment];
                }
                
                if (isValidDataKeyPath) {
                    
                    maximumSegmentLength = MAX([locationKeyPathSegment length], maximumSegmentLength);
                    if ([locationKeyPathSegment rangeOfCharacterFromSet:restrictedSymbols].location != NSNotFound) {
                        
                        isValidDataKeyPath = NO;
                        if ([locationKeyPathSegment rangeOfString:@"!"].location != NSNotFound &&
                            [NSArray pn_isEntryIndexString:locationKeyPathSegment]) {
                            
                            isValidDataKeyPath = YES;
                        }
                    }
                }

                if (isValidDataKeyPath) {

                    NSArray *restOfSymbols = [locationKeyPathSegment componentsSeparatedByCharactersInSet:allowedSymbols];
                    isValidDataKeyPath = ([[restOfSymbols componentsJoinedByString:@""] length] == 0);
                }

                *locationKeyPathSegmentEnumeratorStop = !isValidDataKeyPath;
            }];

            isValidDataKeyPath = (isValidDataKeyPath ? maximumSegmentLength < kPNMaximumSegmentLength : isValidDataKeyPath);

            *locationKeyPathEnumeratorStop = !isValidDataKeyPath;
        }];
    }
    
    
    return isValidDataKeyPath;
}

- (void)processSynchronizationTask:(PNDataSynchronizationTask *)task withError:(PNError *)error {
    
    PNObjectInformation *objectInformation = task.objectInformation;
    PNDataSynchronizationTaskStep step = (!error ? [task nextStep] : [task lastStep]);
    switch (step) {
            
        case PNDataSynchronizationTaskUnsubscribeStep:
            {
                self.asyncLockingOperationInProgress = NO;
                [self unsubscribeFrom:task.irrelevantDataFeedObjects];
            }
            break;
        case PNDataSynchronizationTaskSubscribeStep:
            {
                self.asyncLockingOperationInProgress = NO;
                [self subscribeOn:task.relevantDataFeedObjects];
            }
            break;
        case PNDataSynchronizationTaskFetchStep:
            {
                self.asyncLockingOperationInProgress = NO;
                [self fetchRemoteObjectData:objectInformation.identifier atLocation:[task nextDataLocation]
                               snapshotDate:objectInformation.lastSnaphostTimeToken
                              nextPageToken:objectInformation.nextDataPageToken
                     reschedulingMethodCall:NO andCompletionHandlingBlock:nil];
            }
            break;
        case PNDataSynchronizationTaskStartCompletedStep:
            {
                if (!error) {
                    
                    [self handleSynchronizationCompletionFor:objectInformation];
                }
                else {
                    
                    [error replaceAssociatedObject:objectInformation];
                    [self notifyDelegateAboutRemoteObjectSynchronizationDidFailWithError:error];
                }
            }
            break;
        case PNDataSynchronizationTaskStopCompletedStep:
            {
                if (!error) {
                    
                    [self handleSynchronizationStopCompletionFor:objectInformation];
                }
                else {
                    
                    [error replaceAssociatedObject:objectInformation];
                    [self notifyDelegateAboutRemoteObjectSynchronizationStopDidFailWithError:error];
                }
            }
            break;
            
        default:
            
            break;
    }
}

- (void)handleSynchronizationCompletionFor:(PNObjectInformation *)objectInformation {
    
    [self pn_dispatchBlock:^{
        
        [self checkShouldChannelNotifyAboutEvent:self.messagingChannel
                                       withBlock:^(BOOL shouldNotify) {
            
            [self handleLockingOperationBlockCompletion:^{
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.remoteObjectSynchronizationStartCompleted,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                if (shouldNotify) {
                    
                    // Check whether delegate is able to handle push notification enabled event or not
                    SEL selector = @selector(pubnubClient:didStartObjectSynchronization:withDataAtLocations:);
                    if ([self.clientDelegate respondsToSelector:selector]) {

                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.clientDelegate pubnubClient:self
                                didStartObjectSynchronization:objectInformation.object
                                          withDataAtLocations:objectInformation.dataLocations];
                        });
                    }
                    
                    [self sendNotification:kPNObjectSynchronizationDidStartNotification
                                withObject:objectInformation];
                }
            }
                                        shouldStartNext:YES];
        }];
    }];
}

- (void)notifyDelegateAboutRemoteObjectSynchronizationDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectSynchronizationStartFailed,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle object synchronization launch error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:objectSynchronization:startDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self objectSynchronization:error.associatedObject
                            startDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNObjectSynchronizationStartDidFailWithErrorNotification withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)handleSynchronizationStopCompletionFor:(PNObjectInformation *)objectInformation {
    
    [self pn_dispatchBlock:^{
        
        [self checkShouldChannelNotifyAboutEvent:self.messagingChannel
                                       withBlock:^(BOOL shouldNotify) {
                                           
           [self handleLockingOperationBlockCompletion:^{
               
               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                   
                   return @[PNLoggerSymbols.api.remoteObjectSynchronizationStopCompleted,
                            [self humanReadableStateFrom:self.state]];
               }];
               
               if (shouldNotify) {
                   
                   // Check whether delegate is able to handle push notification enabled event or not
                   SEL selector = @selector(pubnubClient:didStopObjectSynchronization:);
                   if ([self.clientDelegate respondsToSelector:selector]) {
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           [self.clientDelegate pubnubClient:self
                                didStopObjectSynchronization:objectInformation];
                       });
                   }
                   
                   [self sendNotification:kPNObjectSynchronizationDidStopNotification
                               withObject:objectInformation];
               }
           }
                                       shouldStartNext:YES];
       }];
    }];
}

- (void)notifyDelegateAboutRemoteObjectSynchronizationStopDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectSynchronizationStopFailed,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle object synchronization launch error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:objectSynchronization:stopDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self objectSynchronization:error.associatedObject
                             stopDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNObjectSynchronizationStopDidFailWithErrorNotification
                    withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutRemoteObjectDataFetchDidFailWithError:(PNError *)error {
    
    [self pn_dispatchBlock:^{
        
        PNObjectInformation *objectInformation = error.associatedObject;
        [self.dataSynchronization hasActiveSynchronizationTaskFor:objectInformation.identifier
                                                        withBlock:^(PNDataSynchronizationTask *task,
                                                                    BOOL hasActiveTask,
                                                                    BOOL isSynchronizationStart) {
                                                            
            if (!hasActiveTask) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.remoteObjectDataFetchFailed,
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    // Check whether delegate is able to handle object synchronization launch error or not
                    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:remoteObject:fetchDidFailWithError:)]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.clientDelegate pubnubClient:self remoteObject:error.associatedObject
                                        fetchDidFailWithError:error];
                        });
                    }
                    
                    [self sendNotification:kPNClientObjectDataFetchDidFailWithErrorNotification
                                withObject:error];
                }
                                            shouldStartNext:YES];
            }
            else {
                
                if (isSynchronizationStart) {
                    
                    [self notifyDelegateAboutRemoteObjectSynchronizationDidFailWithError:error];
                }
                else {
                    
                    [self notifyDelegateAboutRemoteObjectSynchronizationStopDidFailWithError:error];
                }
            }
        }];
    }];
}

- (void)notifyDelegateAboutRemoteObjectNextDataPortionFetchDidFailWithError:(PNError *)error {
    
    [self pn_dispatchBlock:^{
        
        PNObjectInformation *objectInformation = error.associatedObject;
        [self.dataSynchronization hasActiveSynchronizationTaskFor:objectInformation.identifier
                                                        withBlock:^(PNDataSynchronizationTask *task,
                                                                    BOOL hasActiveTask,
                                                                    BOOL isSynchronizationStart) {
                                                            
            if (!hasActiveTask) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.remoteObjectDataPortionFetchFailed,
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    // Check whether delegate is able to handle object synchronization launch error or not
                    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:remoteObject:fetchDidFailWithError:)]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.clientDelegate pubnubClient:self remoteObject:error.associatedObject
                                        fetchDidFailWithError:error];
                        });
                    }
                    
                    [self sendNotification:kPNClientObjectDataFetchDidFailWithErrorNotification
                                withObject:error];
                }
                                            shouldStartNext:YES];
            }
            else {
                
                if (isSynchronizationStart) {
                    
                    [self notifyDelegateAboutRemoteObjectSynchronizationDidFailWithError:error];
                }
                else {
                    
                    [self notifyDelegateAboutRemoteObjectSynchronizationStopDidFailWithError:error];
                }
            }
        }];
    }];
}

- (void)notifyDelegateAboutRemoteObjectDataPushDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPushFailed,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle object synchronization launch error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:remoteObject:dataPushDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self remoteObject:error.associatedObject
                         dataPushDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientDataPushToObjectDidFailWithErrorNotification
                    withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutRemoteObjectListPushDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPushToListFailed,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle object synchronization launch error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:remoteObject:dataPushDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self remoteObject:error.associatedObject
                         dataPushDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientDataPushToObjectDidFailWithErrorNotification
                    withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutRemoteObjectDataReplaceDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataReplaceFailed,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle object synchronization launch error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:remoteObject:dataReplaceDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self remoteObject:error.associatedObject
                      dataReplaceDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientObjectDataReplaceDidFailWithErrorNotification
                    withObject:error];
    }
                                shouldStartNext:YES];
}

- (void)notifyDelegateAboutRemoteObjectDataRemoveDidFailWithError:(PNError *)error {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataRemoveFailed,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        // Check whether delegate is able to handle object synchronization launch error or not
        if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:remoteObject:dataRemoveDidFailWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.clientDelegate pubnubClient:self remoteObject:error.associatedObject
                       dataRemoveDidFailWithError:error];
            });
        }
        
        [self sendNotification:kPNClientObjectDataRemoveDidFailWithErrorNotification
                    withObject:error];
    }
                                shouldStartNext:YES];
}


#pragma mark - Messaging channel delegate methods

- (void)                messagingChannel:(PNMessagingChannel *)messagingChannel
  didSubscribeOnRemoteObjectsChangesFeed:(NSArray *)channelObjects
                               sequenced:(BOOL)isSequenced {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [self.dataSynchronization handleSynchronizationOn:channelObjects
                                                withBlock:^(NSArray *synchronizationTasks) {
                                                    
            [synchronizationTasks enumerateObjectsUsingBlock:^(PNDataSynchronizationTask *task,
                                                               NSUInteger taskIdx,
                                                               BOOL *taskEnumeratorStop) {
                
                [self processSynchronizationTask:task withError:nil];
            }];
                                                    
            if ([synchronizationTasks count] == 0) {
                
                [self handleLockingOperationComplete:YES];
            }
        }];
    };
    
    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {
        
        [self pn_dispatchBlock:^{
            
            if (!isSequenced) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:NO];
            }
            else {
                
                handlingBlock(shouldNotify);
            }
            
            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)                    messagingChannel:(PNMessagingChannel *)messagingChannel
  didFailSubscribeOnRemoteObjectsChangesFeed:(NSArray *)channelObjects
                                   withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [self.dataSynchronization handleSynchronizationError:error onObjects:channelObjects
                                                   withBlock:^(NSArray *synchronizationTasks) {
                                                       
           [synchronizationTasks enumerateObjectsUsingBlock:^(PNDataSynchronizationTask *task,
                                                              NSUInteger taskIdx,
                                                              BOOL *taskEnumeratorStop) {
               
               [self processSynchronizationTask:task withError:error];
           }];
           
           if ([synchronizationTasks count] == 0) {
               
               [self handleLockingOperationComplete:YES];
           }
       }];
    };
    
    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {
        
        [self pn_dispatchBlock:^{
            
            if (!isSequenced) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:NO];
            }
            else {
                
                handlingBlock(shouldNotify);
            }
            
            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)                    messagingChannel:(PNMessagingChannel *)messagingChannel
  didUnsubscribeFromRemoteObjectsChangesFeed:(NSArray *)channelObjects
                                   sequenced:(BOOL)isSequenced {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [self.dataSynchronization handleSynchronizationStopOn:channelObjects
                                                    withBlock:^(NSArray *synchronizationTasks) {
                                                    
            [synchronizationTasks enumerateObjectsUsingBlock:^(PNDataSynchronizationTask *task,
                                                               NSUInteger taskIdx,
                                                               BOOL *taskEnumeratorStop) {
                
                [self processSynchronizationTask:task withError:nil];
            }];
            
            if ([synchronizationTasks count] == 0) {
                
                [self handleLockingOperationComplete:YES];
            }
        }];
    };
    
    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {
        
        [self pn_dispatchBlock:^{
            
            if (!isSequenced) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:NO];
            }
            else {
                
                handlingBlock(shouldNotify);
            }
            
            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)                        messagingChannel:(PNMessagingChannel *)messagingChannel
  didFailUnsubscribeFromRemoteObjectsChangesFeed:(NSArray *)channelObjects
                                       withError:(PNError *)error sequenced:(BOOL)isSequenced {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [self.dataSynchronization handleSynchronizationError:error onObjects:channelObjects
                                                       withBlock:^(NSArray *synchronizationTasks) {
                                                       
           [synchronizationTasks enumerateObjectsUsingBlock:^(PNDataSynchronizationTask *task,
                                                              NSUInteger taskIdx,
                                                              BOOL *taskEnumeratorStop) {
               
               [self processSynchronizationTask:task withError:error];
           }];
           
           if ([synchronizationTasks count] == 0) {
               
               [self handleLockingOperationComplete:YES];
           }
       }];
    };
    
    [self checkShouldChannelNotifyAboutEvent:messagingChannel withBlock:^(BOOL shouldNotify) {
        
        [self pn_dispatchBlock:^{
            
            if (!isSequenced) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:NO];
            }
            else {
                
                handlingBlock(shouldNotify);
            }
            
            [self launchHeartbeatTimer];
        }];
    }];
}

- (void)        messagingChannel:(PNMessagingChannel *)messagingChannel
  didReceiveSynchronizationEvent:(PNDataSynchronizationEvent *)event {

    [self pn_dispatchBlock:^{

        [self.dataSynchronization handleSynchronizationEvent:event
                                                   withBlock:^(PNObject *object, NSArray *locations,
                                                           BOOL modificationCompleted) {

            [self checkShouldChannelNotifyAboutEvent:self.messagingChannel
                                           withBlock:^(BOOL shouldNotify) {

                if (modificationCompleted && shouldNotify) {

                    // Check whether delegate is able to handle object synchronization launch error or not
                    if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReceiveModificationEventFor:atLocations:)]) {

                        dispatch_async(dispatch_get_main_queue(), ^{

                            [self.clientDelegate pubnubClient:self didReceiveModificationEventFor:object
                                                  atLocations:locations];
                        });
                    }

                    PNObjectInformation *objectInformation = [PNObjectInformation objectInformation:object.identifier
                                                                                      dataLocations:locations
                                                                                  snapshotTimeToken:nil];
                    objectInformation.object = object;

                    [self sendNotification:kPNObjectModificationEventNotification
                                withObject:objectInformation];
                }
          }];
        }];
    }];
}


#pragma mark - Service channel delegate methods

- (void)    serviceChannel:(PNServiceChannel *)channel
  didFetchRemoteObjectData:(PNObjectInformation *)objectInformation {
    
    [self pn_dispatchBlock:^{
        
        [self.dataSynchronization hasActiveSynchronizationTaskFor:objectInformation.identifier
                                                        withBlock:^(PNDataSynchronizationTask *task,
                                                                    BOOL hasActiveTask,
                                                                    BOOL isSynchronizationStart) {
                                                            
            void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
                
                [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                    
                    return @[PNLoggerSymbols.api.remoteObjectDataFetchCompleted,
                             [self humanReadableStateFrom:self.state]];
                }];
                
                [self.dataSynchronization handleDataFetchCompletionFor:objectInformation
                                                              andBlock:^(PNDataSynchronizationTask *activeTask) {
                                                                  
                                                                  
                    [self pn_dispatchBlock:^{
                        
                        if (hasActiveTask) {
                                                                              
                            [self processSynchronizationTask:activeTask withError:nil];
                        }
                        else {
                            
                            if (shouldNotify) {
                                
                                // Check whether delegate can handle time token retrieval or not
                                if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didFetchRemoteObjectData:)]) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        [self.clientDelegate performSelector:@selector(pubnubClient:didFetchRemoteObjectData:)
                                                                  withObject:self
                                                                  withObject:objectInformation];
                                    });
                                }
                                
                                [self sendNotification:kPNClientDidFetchObjectDataNotification
                                            withObject:objectInformation];
                            }
                        }
                    }];
                }];
            };
            
            [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {
                
                [self handleLockingOperationBlockCompletion:^{
                    
                    handlingBlock(shouldNotify);
                }
                                            shouldStartNext:!hasActiveTask];
            }];
        }];
    }];
}

- (void) serviceChannel:(PNServiceChannel *)channel
           remoteObject:(PNObjectInformation *)objectInformation
  fetchDidFailWithError:(PNError *)error {
    
    [self pn_dispatchBlock:^{
        
        [self.dataSynchronization hasActiveSynchronizationTaskFor:objectInformation.identifier
                                                        withBlock:^(PNDataSynchronizationTask *task,
                                                                    BOOL hasActiveTask,
                                                                    BOOL isSynchronizationStart) {
                                                            
            if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
                
                [self pn_dispatchBlock:^{
                    
                    if (hasActiveTask) {
                        
                        [self processSynchronizationTask:task withError:error];
                    }
                    else {
                        
                        [self.dataSynchronization handleDataFetchFor:objectInformation
                                                       failWithError:error
                                                            andBlock:^{
                                                                
                            [error replaceAssociatedObject:objectInformation];
                            [self notifyDelegateAboutRemoteObjectDataFetchDidFailWithError:error];
                        }];
                    }
                }];
            }
            else {
                
                [self rescheduleMethodCall:^{
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.rescheduleRemoteObjectDataFetch,
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    [self fetchRemoteObjectData:objectInformation.identifier
                                     atLocation:[objectInformation.dataLocations lastObject]
                                   snapshotDate:objectInformation.lastSnaphostTimeToken
                                  nextPageToken:objectInformation.nextDataPageToken
                         reschedulingMethodCall:YES andCompletionHandlingBlock:nil];
                }];
            }
        }];
    }];
}

- (void)                 serviceChannel:(PNServiceChannel *)channel
  didFetchRemoteObjectNextPortionOfData:(PNObjectInformation *)objectInformation {
    
    [self handleLockingOperationBlockCompletion:^{
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPortionFetchCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        [self.dataSynchronization handlePartialDataFetchCompletionFor:objectInformation
                                                             andBlock:^(PNDataSynchronizationTask *activeTask) {
                                                          
            // Request next portion of data
            [self fetchRemoteObjectData:objectInformation.identifier
                             atLocation:[objectInformation.dataLocations lastObject]
                           snapshotDate:objectInformation.lastSnaphostTimeToken
                          nextPageToken:objectInformation.nextDataPageToken
                 reschedulingMethodCall:NO andCompletionHandlingBlock:nil];
        }];
    }
                                shouldStartNext:NO];
}

- (void)                  serviceChannel:(PNServiceChannel *)channel
                            remoteObject:(PNObjectInformation *)objectInformation
  nextPortionOfDatafetchDidFailWithError:(PNError *)error {
    
    [self pn_dispatchBlock:^{
        
        [self.dataSynchronization hasActiveSynchronizationTaskFor:objectInformation.identifier
                                                        withBlock:^(PNDataSynchronizationTask *task,
                                                                    BOOL hasActiveTask,
                                                                    BOOL isSynchronizationStart) {
                                                            
            if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
                
                [self pn_dispatchBlock:^{
                    
                    if (hasActiveTask) {
                        
                        [self processSynchronizationTask:task withError:error];
                    }
                    else {
                        
                        [self.dataSynchronization handleDataFetchFor:objectInformation
                                                       failWithError:error
                                                            andBlock:^{
                                                                
                            [error replaceAssociatedObject:objectInformation];
                            [self notifyDelegateAboutRemoteObjectNextDataPortionFetchDidFailWithError:error];
                        }];
                    }
                }];
            }
            else {
                                                                        
                [self rescheduleMethodCall:^{
                    
                    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                        
                        return @[PNLoggerSymbols.api.rescheduleRemoteObjectDataPortionFetch,
                                 [self humanReadableStateFrom:self.state]];
                    }];
                    
                    [self fetchRemoteObjectData:objectInformation.identifier
                                     atLocation:[objectInformation.dataLocations lastObject]
                                   snapshotDate:objectInformation.lastSnaphostTimeToken
                                  nextPageToken:objectInformation.nextDataPageToken
                         reschedulingMethodCall:YES
                     andCompletionHandlingBlock:nil];
                }];
            }
        }];
    }];
}

- (void)     serviceChannel:(PNServiceChannel *)channel
  didPushDataToRemoteObject:(PNObjectInformation *)objectInformation {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPushCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        if (shouldNotify) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didPushDataToRemoteObject:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.clientDelegate performSelector:@selector(pubnubClient:didPushDataToRemoteObject:)
                                              withObject:self
                                              withObject:objectInformation];
                });
            }
            
            [self sendNotification:kPNClientDidPushDataToObjectNotification withObject:objectInformation];
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {
        
        [self handleLockingOperationBlockCompletion:^{
            
            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)    serviceChannel:(PNServiceChannel *)channel
              remoteObject:(PNObjectInformation *)objectInformation
  dataPushDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:objectInformation];
        [self notifyDelegateAboutRemoteObjectDataPushDidFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleRemoteObjectDataPush,
                         [self humanReadableStateFrom:self.state]];
            }];
            
            [self pushData:objectInformation.data toRemoteObject:objectInformation.identifier
                atLocation:[objectInformation.dataLocations lastObject] reschedulingMethodCall:YES
withCompletionHandlingBlock:nil];
        }];
    }
}

- (void)           serviceChannel:(PNServiceChannel *)channel
  didPushDataToListInRemoteObject:(PNObjectInformation *)objectInformation
                   withSortingKey:(NSString *)entriesSortingKey {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataPushToListCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        if (shouldNotify) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didPushDataToRemoteObject:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.clientDelegate performSelector:@selector(pubnubClient:didPushDataToRemoteObject:)
                                              withObject:self
                                              withObject:objectInformation];
                });
            }
            
            [self sendNotification:kPNClientDidPushDataToObjectNotification withObject:objectInformation];
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {
        
        [self handleLockingOperationBlockCompletion:^{
            
            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)          serviceChannel:(PNServiceChannel *)channel
                    remoteObject:(PNObjectInformation *)objectInformation
  dataPushToListDidFailWithError:(PNError *)error
                   andSortingKey:(NSString *)entriesSortingKey {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:objectInformation];
        [self notifyDelegateAboutRemoteObjectListPushDidFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleRemoteObjectDataPushToList,
                         [self humanReadableStateFrom:self.state]];
            }];
            
            [self pushObjects:objectInformation.data toRemoteObject:objectInformation.identifier
                   atLocation:[objectInformation.dataLocations lastObject]
               withSortingKey:entriesSortingKey reschedulingMethodCall:YES
   andCompletionHandlingBlock:nil];
        }];
    }
}

- (void)      serviceChannel:(PNServiceChannel *)channel
  didReplaceRemoteObjectData:(PNObjectInformation *)objectInformation {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataReplaceCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        if (shouldNotify) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didReplaceRemoteObjectData:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.clientDelegate performSelector:@selector(pubnubClient:didReplaceRemoteObjectData:)
                                              withObject:self
                                              withObject:objectInformation];
                });
            }
            
            [self sendNotification:kPNClientDidReplaceObjectDataNotification withObject:objectInformation];
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {
        
        [self handleLockingOperationBlockCompletion:^{
            
            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)       serviceChannel:(PNServiceChannel *)channel
                 remoteObject:(PNObjectInformation *)objectInformation
  dataReplaceDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:objectInformation];
        [self notifyDelegateAboutRemoteObjectDataReplaceDidFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleRemoteObjectDataReplace,
                         [self humanReadableStateFrom:self.state]];
            }];
            
            [self replaceRemoteObjectData:objectInformation.identifier
                               atLocation:[objectInformation.dataLocations lastObject]
                                  witData:objectInformation.data reschedulingMethodCall:YES
               andCompletionHandlingBlock:nil];
        }];
    }
}

- (void)     serviceChannel:(PNServiceChannel *)channel
  didRemoveRemoteObjectData:(PNObjectInformation *)objectInformation {
    
    void(^handlingBlock)(BOOL) = ^(BOOL shouldNotify){
        
        [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
            
            return @[PNLoggerSymbols.api.remoteObjectDataRemoveCompleted,
                     [self humanReadableStateFrom:self.state]];
        }];
        
        if (shouldNotify) {
            
            // Check whether delegate can handle time token retrieval or not
            if ([self.clientDelegate respondsToSelector:@selector(pubnubClient:didRemoveRemoteObjectData:)]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.clientDelegate performSelector:@selector(pubnubClient:didRemoveRemoteObjectData:)
                                              withObject:self
                                              withObject:objectInformation];
                });
            }
            
            [self sendNotification:kPNClientDidRemoveObjectDataNotification withObject:objectInformation];
        }
    };
    
    [self checkShouldChannelNotifyAboutEvent:channel withBlock:^(BOOL shouldNotify) {
        
        [self handleLockingOperationBlockCompletion:^{
            
            handlingBlock(shouldNotify);
        }
                                    shouldStartNext:YES];
    }];
}

- (void)      serviceChannel:(PNServiceChannel *)channel
                remoteObject:(PNObjectInformation *)objectInformation
  dataRemoveDidFailWithError:(PNError *)error {
    
    if (error.code != kPNRequestCantBeProcessedWithOutRescheduleError) {
        
        [error replaceAssociatedObject:objectInformation];
        [self notifyDelegateAboutRemoteObjectDataRemoveDidFailWithError:error];
    }
    else {
        
        [self rescheduleMethodCall:^{
            
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.rescheduleRemoteObjectDataRemove,
                         [self humanReadableStateFrom:self.state]];
            }];
            
            [self removeRemoteObjectData:objectInformation.identifier
                              atLocation:[objectInformation.dataLocations lastObject]
                  reschedulingMethodCall:YES withCompletionHandlingBlock:nil];
        }];
    }
}

#pragma mark -


@end
