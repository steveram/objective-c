#import "PubNub.h"


#pragma mark Class forward

@class PNObject;


/**
 @brief      Base class extension which provide methods for remote data object manipulation.
 
 @discussion \b PubNub service provides cloud storage for your information. It can be treated as
             simple database where data stored in dictionary and ordered lists.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface PubNub (DataSynchronization)


#pragma mark - Instance methods

#pragma mark - Synchronization methods

/**
 @brief      Allow to audit all specific remote object data synchronization paths on which local
             copy accept modification events through synchronization channels.
 
 @discussion Synchronization API allow to specify path to piece of remote object information on 
             which client should be synchronized and observe changes on it. This method allow
             to retrieve list of all paths for which synchronization has been started.

 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 // Synchronization code with remote data object //
 NSLog(@"Data paths for 'chess' remote data object: %@", 
       [pubNub synchronizedDataLocationsForRemoteObject:@"chess"]);
 @endcode
 
 @param objectIdentifier Reference on remote object identifier for which \b PubNub client should
                         look up in local cache list of data paths for which synchronization has
                         been started.
 
 @return \c nil will be returned in case if paths has been requested for object which currently
         invalidated or never synchronized yet. Empty array will be returned in case if whole
         remote object has been synchronized with object which locally represent it 
         (\b PNObject). List of data paths will be returned in case if synchronization has been
         launched for paerticular piece of remote object.
 
 @since <#version number#>
 */
- (NSArray *)synchronizedDataLocationsForRemoteObject:(NSString *)objectIdentifier;

/**
 @brief      Synchronize local copy of the object with data stored in \b PubNub cloud under 
             specified location.
 
 @discussion If there was no local copy or partial local copy doesn't have any data for specified
             location remote object will be downloaded and stored. Any updates from other clients
             on data at specified location will be delivered via \a modification events and local
             copy will always be up-to-date.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub synchronizeRemoteObject:@"chess" withDataAtLocations:@[@"boards",@"leaderboard"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didStartObjectSynchronization:(PNObject *)object
   withDataAtLocation:(NSArray *)locations {
 
     // PubNub client successfully completed remote 'object' synchronization.
     // 'locations' contains list of location key-paths if synchronized only pieces of remote 
     // object.
 }
 
 - (void)   pubnubClient:(PubNub *)client objectSynchronization:(PNObjectInformation *)objectInformation
   startDidFailWithError:(PNError *)error {
     
     // PubNub client failed to synchronize remote data object. 'objectInformation' contains
     // information about object which tried to synchronize with local copy and list of location
     // key-paths if only pieces of remote data object has been syncrhonized.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe synchronization process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectSynchronizationStartObserver:self 
                                                     withCallbackBlock:^(PNObject *object, 
                                                                         NSArray *locations,
                                                                         PNError *error){
 
     if (!error) {
         
         // PubNub client successfully completed remote 'object' synchronization.
         // 'locations' contains list of location key-paths if synchronized only pieces of remote
         // object.
     }
     else {
 
         // PubNub client failed to synchronize remote data object. 'objectInformation' contains
         // information about object which tried to synchronize with local copy and list of 
         // location key-paths if only pieces of remote data object has been syncrhonized.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header 
         // file and use -localizedDescription / -localizedFailureReason and 
         // -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' reference on PNObjectFetchInformation instance which
         // contains information about object which tried to synchronize with local copy and list
         // of location key-paths if only pieces of remote data object has been syncrhonized.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications:
 kPNObjectSynchronizationDidStartNotification and
 kPNObjectSynchronizationStartDidFailWithErrorNotification.
 
 @param objectIdentifier Reference on remote object identifier which should be pulled to the
                         local copy.
 @param locations        Key-paths to portions of data which should be in sync with \b PubNub 
                         cloud object. In case if \c nil or empty array is passed, whole object
                         from \b PubNub cloud will be synchronized with local object copy.
 
 @note Synchronization events will keep arrive for particular remote object till \b PubNub client
       will stop synchronization on it for all particular data locations (if has been used during
       synchronization launch process).
 
 @since <#version number#>
 */
- (void)synchronizeRemoteObject:(NSString *)objectIdentifier
            withDataAtLocations:(NSArray *)locations;

/**
 @brief      Synchronize local copy of the object with data stored in \b PubNub cloud under 
             specified location.
 
 @discussion If there was no local copy or partial local copy doesn't have any data for specified
             location remote object will be downloaded and stored. Any updates from other clients
             on data at specified location will be delivered via \a modification events and local
             copy will always be up-to-date.
 
 @code
 @endcode
 This method extends \a -synchronizeRemoteObject:withDataAtLocation: and allow to specify remote
 object synchronization process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub synchronizeRemoteObject:@"chess" withDataAtLocations:@[@"boards",@"leaderboard"]
      andCompletionHandlingBlock:^(PNObject *object, NSArray *locations, PNError *error){

     if (!error) {
         
         // PubNub client successfully completed remote 'object' synchronization.
         // 'locations' contains list of location key-paths if synchronized only pieces of remote
         // object.
     }
     else {
 
         // PubNub client failed to synchronize remote data object. 'objectInformation' contains
         // information about object which tried to synchronize with local copy and list of 
         // location key-paths if only pieces of remote data object has been syncrhonized.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header 
         // file and use -localizedDescription / -localizedFailureReason and 
         // -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' reference on PNObjectFetchInformation instance which
         // contains information about object which tried to synchronize with local copy and list
         // of location key-paths if only pieces of remote data object has been syncrhonized.
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)pubnubClient:(PubNub *)client didStartObjectSynchronization:(PNObject *)object
   withDataAtLocation:(NSArray *)locations {
 
     // PubNub client successfully completed remote 'object' synchronization.
     // 'locations' contains list of location key-paths if synchronized only pieces of remote 
     // object.
 }
 
 - (void)   pubnubClient:(PubNub *)client objectSynchronization:(PNObjectInformation *)objectInformation
   startDidFailWithError:(PNError *)error {
     
     // PubNub client failed to synchronize remote data object. 'objectInformation' contains
     // information about object which tried to synchronize with local copy and list of location
     // key-paths if only pieces of remote data object has been syncrhonized.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe synchronization process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectSynchronizationStartObserver:self 
                                                     withCallbackBlock:^(PNObject *object, 
                                                                         NSArray *locations,
                                                                         PNError *error){
 
     if (!error) {
         
         // PubNub client successfully completed remote 'object' synchronization.
         // 'locations' contains list of location key-paths if synchronized only pieces of remote
         // object.
     }
     else {
 
         // PubNub client failed to synchronize remote data object. 'objectInformation' contains
         // information about object which tried to synchronize with local copy and list of 
         // location key-paths if only pieces of remote data object has been syncrhonized.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header 
         // file and use -localizedDescription / -localizedFailureReason and 
         // -localizedRecoverySuggestion to get human readable description for error).
         // 'error.associatedObject' reference on PNObjectFetchInformation instance which
         // contains information about object which tried to synchronize with local copy and list
         // of location key-paths if only pieces of remote data object has been syncrhonized.
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNObjectSynchronizationDidStartNotification and
 kPNObjectSynchronizationStartDidFailWithErrorNotification.
 
 @param objectIdentifier Reference on remote object identifier which should be pulled to the
                         local copy.
 @param locations        Key-paths to portions of data which should be in sync with \b PubNub 
                         cloud object. In case if \c nil or empty array is passed, whole object
                         from \b PubNub cloud will be synchronized with local object copy.
 @param handlerBlock     The block which will be called by \b PubNub client during object 
                         synchronization process change. The block takes three arguments:
                         \c object - reference on \b PNObject which is used to represent object
                         from \b PubNub cloud locally; \c locations - key-paths to portions of 
                         data which should be in sync with \b PubNub cloud object (\c nil in case
                         if whole object synchronization has been requested); \c error -
                         describes what exactly went wrong (check error code and compare it with 
                         \b PNErrorCodes ).
 
 @note Synchronization events will keep arrive for particular remote object till \b PubNub client
       will stop synchronization on it for all particular data locations (if has been used during
       synchronization launch process).
 
 @since <#version number#>
 */
- (void)synchronizeRemoteObject:(NSString *)objectIdentifier withDataAtLocations:(NSArray *)locations
     andCompletionHandlingBlock:(PNRemoteObjectSynchronizationStartHandlerBlock)handlerBlock;

/**
 @brief      Stop remote object synchronization with local copy under specified data location
             key-paths.
 
 @discussion This process will terminate synchronization process for particular data pieces
             specified by key-paths. If synchronization will be stopped for last piece of data 
             local copy will be invalidated and all cached data will be cleared.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub stopRemoteObjectSynchronization:@"chess" withDataAtLocations:@[@"boards"]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)          pubnubClient:(PubNub *)client
   didStopObjectSynchronization:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully stopped remote object synchronization. 
     // 'objectInformation' contains information about object for which client tried to stop 
     // synchronization with local copy and list of location key-paths if only pieces of remote
     // data object has been syncrhonized.
 }
 
 - (void)  pubnubClient:(PubNub *)client
  objectSynchronization:(PNObjectInformation *)objectInformation
   stopDidFailWithError:(PNError *)error {
     
     // PubNub client failed to stop remote data object synchronization. 'objectInformation' 
     // contains information about object for which client tried to stop synchronization with 
     // local copy and list of location key-paths if only pieces of remote data object has been
     // syncrhonized.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe synchronization process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectSynchronizationStopObserver:self
                                                    withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                                        PNError *error){
 
     if (!error) {
         
         // PubNub client successfully stopped remote object synchronization. 
         // 'objectInformation' contains information about object for which client tried to stop
         // synchronization with local copy and list of location key-paths if only pieces of 
         // remote data object has been syncrhonized.
     }
     else {
 
         // PubNub client failed to stop remote data object synchronization. 'objectInformation' 
         // contains information about object for which client tried to stop synchronization with
         // local copy and list of location key-paths if only pieces of remote data object has 
         // been syncrhonized.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header 
         // file and use -localizedDescription / -localizedFailureReason and 
         // -localizedRecoverySuggestion to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNObjectSynchronizationDidStopNotification and
 kPNObjectSynchronizationStopDidFailWithErrorNotification.
 
 @param objectIdentifier Reference on remote object identifier for which client should stop
                         synchronization process.
 @param locations        Key-paths to portions of data for which client should stop sync with 
                         \b PubNub cloud object. In case if \c nil or empty array is passed, 
                         client will try to stop synchronization for whole object.
 
 @note Local copy and cache will be cleared only if \b PubNub client will stop synchronization 
       for all particular data locations (if has been specified during synchronization start 
       process).
 @note If \b PubNub client has been synchronized only some pieces of remote data object 
       (particular data location key-paths has been provided during synchronization launch 
       process) this method won't take any effect.
       To stop synchronization for whole object at once if data piece locations has been
       specified try to use \c -stopRemoteObjectSynchronization:withDataAtLocations: and pass
       all locations for which synchronization has been done 
       (\c -synchronizedDataLocationsForRemoteObject: can return full list of data location 
       key-paths).
 
 @since <#version number#>
 */
- (void)stopRemoteObjectSynchronization:(NSString *)objectIdentifier
                    withDataAtLocations:(NSArray *)locations;

/**
 @brief      Stop remote object synchronization with local copy under specified data location
             key-paths.
 
 @discussion This process will terminate synchronization process for particular data pieces
             specified by key-paths. If synchronization will be stopped for last piece of data 
             local copy will be invalidated and all cached data will be cleared.
 
 @code
 @endcode
 This method extends \a -stopRemoteObjectSynchronization:withDataAtLocations: and allow to 
 specify remote object synchronization stop process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub stopRemoteObjectSynchronization:@"chess" withDataAtLocations:@[@"boards"]
             withCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error){
 
     if (!error) {
         
         // PubNub client successfully stopped remote object synchronization. 
         // 'objectInformation' contains information about object for which client tried to stop
         // synchronization with local copy and list of location key-paths if only pieces of 
         // remote data object has been syncrhonized.
     }
     else {
 
         // PubNub client failed to stop remote data object synchronization. 'objectInformation' 
         // contains information about object for which client tried to stop synchronization with
         // local copy and list of location key-paths if only pieces of remote data object has 
         // been syncrhonized.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header 
         // file and use -localizedDescription / -localizedFailureReason and 
         // -localizedRecoverySuggestion to get human readable description for error).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)          pubnubClient:(PubNub *)client
   didStopObjectSynchronization:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully stopped remote object synchronization. 
     // 'objectInformation' contains information about object for which client tried to stop 
     // synchronization with local copy and list of location key-paths if only pieces of remote
     // data object has been syncrhonized.
 }
 
 - (void)  pubnubClient:(PubNub *)client
  objectSynchronization:(PNObjectInformation *)objectInformation
   stopDidFailWithError:(PNError *)error {
     
     // PubNub client failed to stop remote data object synchronization. 'objectInformation' 
     // contains information about object for which client tried to stop synchronization with 
     // local copy and list of location key-paths if only pieces of remote data object has been
     // syncrhonized.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe synchronization process from any place in your application using 
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectSynchronizationStopObserver:self
                                                    withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                                        PNError *error){
 
     if (!error) {
         
         // PubNub client successfully stopped remote object synchronization. 
         // 'objectInformation' contains information about object for which client tried to stop
         // synchronization with local copy and list of location key-paths if only pieces of 
         // remote data object has been syncrhonized.
     }
     else {
 
         // PubNub client failed to stop remote data object synchronization. 'objectInformation' 
         // contains information about object for which client tried to stop synchronization with
         // local copy and list of location key-paths if only pieces of remote data object has 
         // been syncrhonized.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header 
         // file and use -localizedDescription / -localizedFailureReason and 
         // -localizedRecoverySuggestion to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNObjectSynchronizationDidStopNotification and
 kPNObjectSynchronizationStopDidFailWithErrorNotification.
 
 @param objectIdentifier Reference on remote object identifier for which client should stop
                         synchronization process.
 @param locations        Key-paths to portions of data for which client should stop sync with 
                         \b PubNub cloud object. In case if \c nil or empty array is passed, 
                         client will try to stop synchronization for whole object.
 @param handlerBlock     The block which will be called by \b PubNub client during object 
                         synchronization process change. The block takes two arguments:
                         \c objectInformation - contains information about object for which 
                         client tried to stop synchronization with local copy and list of 
                         location key-paths if only pieces of remote data object has been
                         syncrhonized; \c error - describes what exactly went wrong (check error
                         code and compare it with \b PNErrorCodes ).
 
 @note Local copy and cache will be cleared only if \b PubNub client will stop synchronization 
       for all particular data locations (if has been specified during synchronization start 
       process).
 @note If \b PubNub client has been synchronized only some pieces of remote data object 
       (particular data location key-paths has been provided during synchronization launch 
       process) this method won't take any effect.
       To stop synchronization for whole object at once if data piece locations has been
       specified try to use \c -stopRemoteObjectSynchronization:withDataAtLocations: and pass
       all locations for which synchronization has been done 
       (\c -synchronizedDataLocationsForRemoteObject: can return full list of data location 
       key-paths).
 
 @since <#version number#>
 */
- (void)stopRemoteObjectSynchronization:(NSString *)objectIdentifier
                    withDataAtLocations:(NSArray *)locations
            withCompletionHandlingBlock:(PNRemoteObjectSynchronizationStopHandlerBlock)handlerBlock;


#pragma mark - Remote data object manipulation methods

/**
 @brief      Fetch remote object's data from \b PubNub cloud.
 
 @discussion In case if there is no reason to observe for changes of remote data object all the
             time this method allow to pull data for whole object or it's piece from \b PubNub 
             cloud.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub fetchRemoteObjectData:@"chess" atLocation:@"leaderboard"];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)      pubnubClient:(PubNub *)client
   didFetchRemoteObjectData:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully fetched remote object's data.
     // 'objectInformation' contains information about object for which client tried to receive
     // data and location key-path (if specified) from which data has been requested.
 }
 
- (void)   pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
  fetchDidFailWithError:(PNError *)error {
     
     // PubNub client failed to fetch remote object's data. 'objectInformation'
     // contains information about object for which client tried to receive data and location 
     // key-path (if specified) from which data has been requested.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe remote object data fetch process from any place in your application
 using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataFetchObserver:self
                                          withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                              PNError *error){
 
     if (!error) {
         
         // PubNub client successfully fetched remote object's data.
         // 'objectInformation' contains information about object for which client tried to receive
         // data and location key-path (if specified) from which data has been requested.
     }
     else {
 
         // PubNub client failed to fetch remote object's data. 'objectInformation'
         // contains information about object for which client tried to receive data and location 
         // key-path (if specified) from which data has been requested.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidFetchObjectDataNotification and
 kPNClientObjectDataFetchDidFailWithErrorNotification.
 
 @param objectIdentifier Remote data object identifier for which data should be retrieved from
                         \b PubNub cloud.
 @param location         Remote object's data location key-path inside of \b PubNub cloud.
                         In case if \c nil has been provided, \b PubNub client will try to fetch
                         all data from \b PubNub cloud for remote data object.
 
 @since <#version number#>
 */
- (void)fetchRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location;

/**
 @brief      Fetch remote object's data from \b PubNub cloud.
 
 @discussion In case if there is no reason to observe for changes of remote data object all the
             time this method allow to pull data for whole object or it's piece from \b PubNub 
             cloud.
 
 @code
 @endcode
 This method extends \a -fetchRemoteObjectData:atLocation: and allow to specify remote object 
 data fetch process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub fetchRemoteObjectData:@"chess" atLocation:@"leaderboard"
    andCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error){
 
     if (!error) {
         
         // PubNub client successfully fetched remote object's data.
         // 'objectInformation' contains information about object for which client tried to receive
         // data and location key-path (if specified) from which data has been requested.
     }
     else {
 
         // PubNub client failed to fetch remote object's data. 'objectInformation'
         // contains information about object for which client tried to receive data and location 
         // key-path (if specified) from which data has been requested.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)      pubnubClient:(PubNub *)client
   didFetchRemoteObjectData:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully fetched remote object's data.
     // 'objectInformation' contains information about object for which client tried to receive
     // data and location key-path (if specified) from which data has been requested.
 }
 
- (void)   pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
  fetchDidFailWithError:(PNError *)error {
     
     // PubNub client failed to fetch remote object's data. 'objectInformation'
     // contains information about object for which client tried to receive data and location 
     // key-path (if specified) from which data has been requested.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe remote object data fetch process from any place in your application
 using \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataFetchObserver:self
                                          withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                              PNError *error){
 
     if (!error) {
         
         // PubNub client successfully fetched remote object's data.
         // 'objectInformation' contains information about object for which client tried to receive
         // data and location key-path (if specified) from which data has been requested.
     }
     else {
 
         // PubNub client failed to fetch remote object's data. 'objectInformation'
         // contains information about object for which client tried to receive data and location 
         // key-path (if specified) from which data has been requested.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidFetchObjectDataNotification and
 kPNClientObjectDataFetchDidFailWithErrorNotification.
 
 @param objectIdentifier Remote data object identifier for which data should be retrieved from
                         \b PubNub cloud.
 @param location         Remote object's data location key-path inside of \b PubNub cloud.
                         In case if \c nil has been provided, \b PubNub client will try to fetch
                         all data from \b PubNub cloud for remote data object.
 @param handlerBlock     The block which will be called during remote object data fetch process
                         state change. The block takes two arguments: \c objectInformation - 
                         contains information about object for which
                         client tried to fetch data from \b PubNub cloud and data location 
                         key-path if only pieces of remote data object has been requested; 
                         \c error - describes what exactly went wrong (check error code and
                         compare it with \b PNErrorCodes ).
 
 @since <#version number#>
 */
- (void)fetchRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
   andCompletionHandlingBlock:(PNRemoteObjectDataFetchHandlerBlock)handlerBlock;

/**
 @brief      Push new or replace old values inside of remote object's using specified data 
             location key-path in \b PubNub cloud.
 
 @discussion Using this method remote object's data can be altered or added new data using as 
             target provided data location key-path inside of \b PubNub cloud.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub pushData:@{@"title":@"PubNub"} toRemoteObject:@"chess" atLocation:@"boards"];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)       pubnubClient:(PubNub *)client
   didPushDataToRemoteObject:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully pushed data to remote object.
     // 'objectInformation' contains information about object into which client tried to push
     // data and location key-path (if specified) where data should be pushed.
 }
 
 - (void)      pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
   dataPushDidFailWithError:(PNError *)error {
     
     // PubNub client failed to push data to remote object. 'objectInformation'
     // contains information about object into which client tried to push data and location
     // key-path (if specified) where data has be pushed.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data push process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataPushObserver:self
                                         withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                             PNError *error){
 
     if (!error) {
         
         // PubNub client successfully pushed data to remote object.
         // 'objectInformation' contains information about object into which client tried to push
         // data and location key-path (if specified) where data should be pushed.
     }
     else {
 
         // PubNub client failed to push data to remote object. 'objectInformation'
         // contains information about object into which client tried to push data and location
         // key-path (if specified) where data has be pushed.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidPushDataToObjectNotification and
 kPNClientDataPushToObjectDidFailWithErrorNotification.
 
 @param data             Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier Remote data object identifier for which data should be pushed.
 @param location         Remote object's data location key-path inside of \b PubNub cloud.
                         In case if \c nil has been provided, \b PubNub client will try to push
                         data to remote object's root node inside of \b PubNub cloud.
 
 @note In case if client syncrhonized with object for which data has been pushed, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 
 @since <#version number#>
 */
- (void)pushData:(id)data toRemoteObject:(NSString *)objectIdentifier
      atLocation:(NSString *)location;

/**
 @brief      Push new or replace old values inside of remote object's using specified data 
             location key-path in \b PubNub cloud.
 
 @discussion Using this method remote object's data can be altered or added new data using as 
             target provided data location key-path inside of \b PubNub cloud.
 
 @code
 @endcode
 This method extends \a -pushData:toRemoteObject:atLocation: and allow to specify remote object
 data push process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub pushData:@{@"title":@"PubNub"} toRemoteObject:@"chess" atLocation:@"boards"];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)       pubnubClient:(PubNub *)client
   didPushDataToRemoteObject:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully pushed data to remote object.
     // 'objectInformation' contains information about object into which client tried to push
     // data and location key-path (if specified) where data should be pushed.
 }
 
 - (void)      pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
   dataPushDidFailWithError:(PNError *)error {
     
     // PubNub client failed to push data to remote object. 'objectInformation'
     // contains information about object into which client tried to push data and location
     // key-path (if specified) where data has be pushed.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data push process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataPushObserver:self
                                         withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                             PNError *error){
 
     if (!error) {
         
         // PubNub client successfully pushed data to remote object.
         // 'objectInformation' contains information about object into which client tried to push
         // data and location key-path (if specified) where data should be pushed.
     }
     else {
 
         // PubNub client failed to push data to remote object. 'objectInformation'
         // contains information about object into which client tried to push data and location
         // key-path (if specified) where data has be pushed.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidPushDataToObjectNotification and
 kPNClientDataPushToObjectDidFailWithErrorNotification.
 
 @param data             Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier Remote data object identifier for which data should be pushed.
 @param location         Remote object's data location key-path inside of \b PubNub cloud.
                         In case if \c nil has been provided, \b PubNub client will try to push
                         data to remote object's root node inside of \b PubNub cloud.
 @param handlerBlock     Callback block called during data push process state updates. The
                         block takes two arguments: \c objectInformation -
                         contains information about object to which client tried to push data 
                         in \b PubNub cloud, data location key-path if data should be pushed
                         to concrete location and data which has been pushed;
                         \c error - describes what exactly went wrong (check error code and
                         compare it with \b PNErrorCodes ).
 
 @note In case if client syncrhonized with object for which data has been pushed, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 
 @since <#version number#>
 */
- (void)             pushData:(id)data toRemoteObject:(NSString *)objectIdentifier
                   atLocation:(NSString *)location
  withCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock;

/**
 @brief      Push new objects to list inside of remote object using specified data location 
             key-path in \b PubNub cloud.
 
 @discussion Data can be stored in \b PubNub cloud in sorted lists and this method allow to push
             new entries to the end of such list or inside of it if sorting key will allow.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub pushObjects:@[@{@"first_name":@"Joe",@"age":@(27)}, @{@"first_name":@"Bob",@"age":@(21)}]
      toRemoteObject:@"chess" atLocation:@"players" withSortingKey:nil];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)       pubnubClient:(PubNub *)client
   didPushDataToRemoteObject:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully pushed data to remote object.
     // 'objectInformation' contains information about object into which client tried to push
     // data and location key-path (if specified) where data should be pushed.
 }
 
 - (void)      pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
   dataPushDidFailWithError:(PNError *)error {
     
     // PubNub client failed to push data to remote object. 'objectInformation'
     // contains information about object into which client tried to push data and location
     // key-path (if specified) where data has be pushed.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data push process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataPushObserver:self
                                         withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                             PNError *error){
 
     if (!error) {
         
         // PubNub client successfully pushed data to remote object.
         // 'objectInformation' contains information about object into which client tried to push
         // data and location key-path (if specified) where data should be pushed.
     }
     else {
 
         // PubNub client failed to push data to remote object. 'objectInformation'
         // contains information about object into which client tried to push data and location
         // key-path (if specified) where data has be pushed.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidPushDataToObjectNotification and
 kPNClientDataPushToObjectDidFailWithErrorNotification.
 
 @param data              Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier  Remote data object identifier for which data should be pushed.
 @param location          Remote object's data location key-path inside of \b PubNub cloud.
                          In case if \c nil has been provided, \b PubNub client will try to push
                          data to remote object's root node inside of \b PubNub cloud.
 @param entriesSortingKey Allow to manage lexigraphical sorting mechanism by specifying char or
                          word with which will be used during output of sorted list. Only
                          \b [A-Za-z] can be used.
                          If \c nil is passed, then object(s) will be added to the end of the 
                          list.
 
 @note In case if client syncrhonized with object for which data has been pushed, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 @note \c entriesSortingKey can be used only when single entry passed inside of \c data array. 
       If multiple values are passed in this method \c entriesSortingKey will be ignored.
 
 @since <#version number#>
 */
- (void)pushObjects:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
         atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey;

/**
 @brief      Push new objects to list inside of remote object using specified data location 
             key-path in \b PubNub cloud.
 
 @discussion Data can be stored in \b PubNub cloud in sorted lists and this method allow to push
             new entries to the end of such list or inside of it if sorting key will allow.
 
 @code
 @endcode
 This method extends \a -pushObjects:toRemoteObject:atLocation:withSortingKey: and allow to 
 specify remote object data push process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub pushObjects:@[@{@"first_name":@"Joe",@"age":@(27)}, @{@"first_name":@"Bob",@"age":@(21)}]
      toRemoteObject:@"chess" atLocation:@"players" withSortingKey:nil 
  andCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error){
 
     if (!error) {
         
         // PubNub client successfully pushed data to remote object.
         // 'objectInformation' contains information about object into which client tried to push
         // data and location key-path (if specified) where data should be pushed.
     }
     else {
 
         // PubNub client failed to push data to remote object. 'objectInformation'
         // contains information about object into which client tried to push data and location
         // key-path (if specified) where data has be pushed.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)       pubnubClient:(PubNub *)client
   didPushDataToRemoteObject:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully pushed data to remote object.
     // 'objectInformation' contains information about object into which client tried to push
     // data and location key-path (if specified) where data should be pushed.
 }
 
 - (void)      pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
   dataPushDidFailWithError:(PNError *)error {
     
     // PubNub client failed to push data to remote object. 'objectInformation'
     // contains information about object into which client tried to push data and location
     // key-path (if specified) where data has be pushed.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data push process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataPushObserver:self
                                         withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                             PNError *error){
 
     if (!error) {
         
         // PubNub client successfully pushed data to remote object.
         // 'objectInformation' contains information about object into which client tried to push
         // data and location key-path (if specified) where data should be pushed.
     }
     else {
 
         // PubNub client failed to push data to remote object. 'objectInformation'
         // contains information about object into which client tried to push data and location
         // key-path (if specified) where data has be pushed.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidPushDataToObjectNotification and
 kPNClientDataPushToObjectDidFailWithErrorNotification.
 
 @param data              Data which will be pushed to remote object in \b PubNub cloud.
 @param objectIdentifier  Remote data object identifier for which data should be pushed.
 @param location          Remote object's data location key-path inside of \b PubNub cloud.
                          In case if \c nil has been provided, \b PubNub client will try to push
                          data to remote object's root node inside of \b PubNub cloud.
 @param entriesSortingKey Allow to manage lexigraphical sorting mechanism by specifying char or
                          word with which will be used during output of sorted list. Only
                          \b [A-Za-z] can be used.
                          If \c nil is passed, then object(s) will be added to the end of the 
                          list.
 @param handlerBlock      Callback block called during data push process state updates. The
                          block takes two arguments: \c objectInformation -
                          contains information about object to which client tried to push data
                          in \b PubNub cloud, data location key-path if data should be pushed
                          to concrete location and data which has been pushed;
                          \c error - describes what exactly went wrong (check error code and
                          compare it with \b PNErrorCodes ).
 
 @note In case if client syncrhonized with object for which data has been pushed, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 @note \c entriesSortingKey can be used only when single entry passed inside of \c data array. 
       If multiple values are passed in this method \c entriesSortingKey will be ignored.
 
 @since <#version number#>
 */
- (void)         pushObjects:(NSArray *)entries toRemoteObject:(NSString *)objectIdentifier
                  atLocation:(NSString *)location withSortingKey:(NSString *)entriesSortingKey
  andCompletionHandlingBlock:(PNRemoteObjectDataPushHandlerBlock)handlerBlock;

/**
 @brief      Completely replace data stored at specified path in \b PubNub cloud object.
 
 @discussion Using this method it is possible to completely overwrite data stored at specified
             path using the one which has been passed to this method.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub replaceRemoteObjectData:@"chess" atLocation:@"leaderboards" 
                         witData:@[@{@"first_name":@"Joe",@"time":@(1237)}]];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)        pubnubClient:(PubNub *)client
   didReplaceRemoteObjectData:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully replaced data in remote object.
     // 'objectInformation' contains information about object for which client tried to replace
     // data and location key-path (if specified) where new data should be pushed replacing old
     // one.
 }
 
 - (void)         pubnubClient:(PubNub *)client
                  remoteObject:(PNObjectInformation *)objectInformation
   dataReplaceDidFailWithError:(PNError *)error {
 
     // PubNub client failed to replace data in remote object. 'objectInformation'
     // contains information about object for which client tried to replace data and location
     // key-path (if specified) where new data should be pushed replacing old one.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data replacement process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataReplaceObserver:self
                                            withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                                PNError *error){
 
     if (!error) {
         
         // PubNub client successfully replaced data in remote object.
         // 'objectInformation' contains information about object for which client tried to replace
         // data and location key-path (if specified) where new data should be pushed replacing old
         // one.
     }
     else {
 
         // PubNub client failed to replace data in remote object. 'objectInformation'
         // contains information about object for which client tried to replace data and location
         // key-path (if specified) where new data should be pushed replacing old one.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidReplaceObjectDataNotification and
 kPNClientObjectDataReplaceDidFailWithErrorNotification.
 
 @param data              Data which will be used as replacement to the the value stored at 
                          specified location key-path.
 @param objectIdentifier  Remote data object identifier for which data should be pushed.
 @param location          Remote object's data location key-path inside of \b PubNub cloud.
                          In case if \c nil has been provided, \b PubNub client will try to 
                          replace data stored in remote object's root node inside of \b PubNub 
                          cloud.
 
 @note In case if client syncrhonized with object in which data has been replaced, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 
 @since <#version number#>
 */
- (void)replaceRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                        witData:(id)data;

/**
 @brief      Completely replace data stored at specified path in \b PubNub cloud object.
 
 @discussion Using this method it is possible to completely overwrite data stored at specified
             path using the one which has been passed to this method.
 
 @code
 @endcode
 This method extends \a -replaceRemoteObjectData:atLocation:witData: and allow to specify remote
 object data replace process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub replaceRemoteObjectData:@"chess" atLocation:@"leaderboards" 
                         witData:@[@{@"first_name":@"Joe",@"time":@(1237)}] 
      andCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error){
 
     if (!error) {
         
         // PubNub client successfully replaced data in remote object.
         // 'objectInformation' contains information about object for which client tried to replace
         // data and location key-path (if specified) where new data should be pushed replacing old
         // one.
     }
     else {
 
         // PubNub client failed to replace data in remote object. 'objectInformation'
         // contains information about object for which client tried to replace data and location
         // key-path (if specified) where new data should be pushed replacing old one.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)        pubnubClient:(PubNub *)client
   didReplaceRemoteObjectData:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully replaced data in remote object.
     // 'objectInformation' contains information about object for which client tried to replace
     // data and location key-path (if specified) where new data should be pushed replacing old
     // one.
 }
 
 - (void)         pubnubClient:(PubNub *)client
                  remoteObject:(PNObjectInformation *)objectInformation
   dataReplaceDidFailWithError:(PNError *)error {
 
     // PubNub client failed to replace data in remote object. 'objectInformation'
     // contains information about object for which client tried to replace data and location
     // key-path (if specified) where new data should be pushed replacing old one.
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data replacement process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataReplaceObserver:self
                                            withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                                PNError *error){
 
     if (!error) {
         
         // PubNub client successfully replaced data in remote object.
         // 'objectInformation' contains information about object for which client tried to replace
         // data and location key-path (if specified) where new data should be pushed replacing old
         // one.
     }
     else {
 
         // PubNub client failed to replace data in remote object. 'objectInformation'
         // contains information about object for which client tried to replace data and location
         // key-path (if specified) where new data should be pushed replacing old one.
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidReplaceObjectDataNotification and
 kPNClientObjectDataReplaceDidFailWithErrorNotification.
 
 @param data              Data which will be used as replacement to the the value stored at 
                          specified location key-path.
 @param objectIdentifier  Remote data object identifier for which data should be pushed.
 @param location          Remote object's data location key-path inside of \b PubNub cloud.
                          In case if \c nil has been provided, \b PubNub client will try to 
                          replace data stored in remote object's root node inside of \b PubNub 
                          cloud.
 @param handlerBlock      Callback block called during data replacement process state updates. 
                          The block takes two arguments: \c objectInformation -
                          contains information about object for which client tried to replace 
                          piece of data in \b PubNub cloud, data location key-path if data 
                          should be replaced at concrete location and data which has been used
                          for replacement; \c error - describes what exactly went wrong (check 
                          error code and compare it with \b PNErrorCodes ).
 
 @note In case if client syncrhonized with object in which data has been replaced, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 
 @since <#version number#>
 */
- (void)replaceRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
                        witData:(id)data
    andCompletionHandlingBlock:(PNRemoteObjectDataReplaceHandlerBlock)handlerBlock;

/**
 @brief Completely remove data stored at specified path in \b PubNub cloud object.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub removeRemoteObjectData:@"chess" atLocation:@"boards.PubNub"];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)       pubNubClient:(PubNub *)client
   didRemoveRemoteObjectData:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully removed data in remote object.
     // 'objectInformation' contains information about object for which client tried to remove
     // data and location key-path (if specified).
 }
 
 - (void)        pubnubClient:(PubNub *)client
                 remoteObject:(PNObjectInformation *)objectInformation
   dataRemoveDidFailWithError:(PNError *)error {
 
     // PubNub client failed to remove data in remote object. 'objectInformation'
     // contains information about object for which client tried to remove data and location
     // key-path (if specified).
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data removal process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataRemoveObserver:self
                                           withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                               PNError *error){
 
     if (!error) {
         
         // PubNub client successfully removed data in remote object.
         // 'objectInformation' contains information about object for which client tried to remove
         // data and location key-path (if specified).
     }
     else {
 
         // PubNub client failed to remove data in remote object. 'objectInformation'
         // contains information about object for which client tried to remove data and location
         // key-path (if specified).
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidRemoveObjectDataNotification and
 kPNClientObjectDataRemoveDidFailWithErrorNotification.
 
 @param objectIdentifier  Remote data object identifier for which data should be removed.
 @param location          Remote object's data location key-path inside of \b PubNub cloud.
                          In case if \c nil has been provided, \b PubNub client will try to 
                          remove all data stored in remote object's root node inside of \b PubNub
                          cloud.
 
 @note In case if client syncrhonized with object for which data has been removed, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 
 @since <#version number#>
 */
- (void)removeRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location;

/**
 @brief Completely remove data stored at specified path in \b PubNub cloud object.
 
 @code
 @endcode
 This method extends \a -removeRemoteObjectData:atLocation: and allow to specify remote object 
 data removal process state change handler block.
 
 @code
 @endcode
 \b Example:
 
 @code
 PubNub *pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                      andDelegate:self];
 [pubNub connect];
 [pubNub removeRemoteObjectData:@"chess" atLocation:@"boards.PubNub" 
    withCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error){
 
     if (!error) {
         
         // PubNub client successfully removed data in remote object.
         // 'objectInformation' contains information about object for which client tried to remove
         // data and location key-path (if specified).
     }
     else {
 
         // PubNub client failed to remove data in remote object. 'objectInformation'
         // contains information about object for which client tried to remove data and location
         // key-path (if specified).
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode
 
 And handle it with delegates:
 @code
 - (void)       pubNubClient:(PubNub *)client
   didRemoveRemoteObjectData:(PNObjectInformation *)objectInformation {
 
     // PubNub client successfully removed data in remote object.
     // 'objectInformation' contains information about object for which client tried to remove
     // data and location key-path (if specified).
 }
 
 - (void)        pubnubClient:(PubNub *)client
                 remoteObject:(PNObjectInformation *)objectInformation
   dataRemoveDidFailWithError:(PNError *)error {
 
     // PubNub client failed to remove data in remote object. 'objectInformation'
     // contains information about object for which client tried to remove data and location
     // key-path (if specified).
     //
     // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
     // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
     // to get human readable description for error).
 }
 @endcode

 There is also way to observe data removal process from any place in your application using
 \b PNObservationCenter:
 @code
 [pubNub.observationCenter addRemoteObjectDataRemoveObserver:self
                                           withCallbackBlock:^(PNObjectInformation *objectInformation,
                                                               PNError *error){
 
     if (!error) {
         
         // PubNub client successfully removed data in remote object.
         // 'objectInformation' contains information about object for which client tried to remove
         // data and location key-path (if specified).
     }
     else {
 
         // PubNub client failed to remove data in remote object. 'objectInformation'
         // contains information about object for which client tried to remove data and location
         // key-path (if specified).
         //
         // Always check 'error.code' to find out what caused error (check PNErrorCodes header file 
         // and use -localizedDescription / -localizedFailureReason and -localizedRecoverySuggestion 
         // to get human readable description for error).
     }
 }];
 @endcode

 Also observation can be done using \b NSNotificationCenter to observe this notifications: 
 kPNClientDidRemoveObjectDataNotification and
 kPNClientObjectDataRemoveDidFailWithErrorNotification.
 
 @param objectIdentifier  Remote data object identifier for which data should be removed.
 @param location          Remote object's data location key-path inside of \b PubNub cloud.
                          In case if \c nil has been provided, \b PubNub client will try to 
                          remove all data stored in remote object's root node inside of \b PubNub
                          cloud.
 @param handlerBlock      Callback block called during data removal process state updates.
                          The block takes two arguments: \c objectInformation -
                          contains information about object for which client tried to remove
                          piece of data in \b PubNub cloud, data location key-path if data 
                          should be removed at concrete location; \c error - describes what 
                          exactly went wrong (check error code and compare it with
                          \b PNErrorCodes ).
 
 @note In case if client syncrhonized with object for which data has been removed, it will be
       updated only on synchronization event and not at the moment of this request processing
       completion.
 
 @since <#version number#>
 */
- (void)removeRemoteObjectData:(NSString *)objectIdentifier atLocation:(NSString *)location
   withCompletionHandlingBlock:(PNRemoteObjectDataRemoveHandlerBlock)handlerBlock;

#pragma mark -

@end
