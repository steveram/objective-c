//
//  PNNotifications.h
//  pubnub
//
//  This header stores list of all notification
//  names which will be used across PubNub client
//  library.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#ifndef PNNotifications_h
#define PNNotifications_h

/**
 Sent when PubNub client got some error during life time.

 \b userInfo contains \b PNError instead of \a NSDictionary.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientErrorNotification = @"PNClientErrorNotification";

/**
 Sent when \b PubNub client connected to remote \b PubNub services.

 \b userInfo contains reference on \a NSString which represent name of the origin to which \b PubNub client
 successfully connected.
*/
static NSString * const kPNClientDidConnectToOriginNotification = @"PNClientDidConnectToOriginNotification";

/**
 Sent when \b PubNub client is about to connect to remote \b PubNub services.

 \b userInfo contains reference on \a NSString which represent name of the origin to which \b PubNub client
 is about to connect.
 */
static NSString * const kPNClientWillConnectToOriginNotification = @"PNClientWillConnectToOriginNotification";

/**
 Sent when \b PubNub client disconnected from remote \b PubNub services.

 \b userInfo contains reference on \a NSString which represent name of the origin to which \b PubNub client
 successfully disconnected.
 */
static NSString * const kPNClientDidDisconnectFromOriginNotification = @"PNClientDidDisconnectFromOriginNotification";

/**
 Sent when \b PubNub client was unable to connect or because it was unable to complete configuration.

 \b userInfo contains \b PNError instead of \a NSDictionary.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientConnectionDidFailWithErrorNotification = @"PNClientConnectionDidFailWithErrorNotification";

/**
 Sent when \b PubNub client successfully retrieved client state information.

 \b userInfo contains reference on \b PNClient instead of \b NSDictionary which hold information about client
 identifier, channel and state itself.
 */
static NSString * const kPNClientDidReceiveClientStateNotification = @"PNClientDidReceiveClientStateNotification";

/**
 Sent when \b PubNub client did fail to retrieve client state information.

 \b userInfo contains \b PNError instead of \a NSDictionary. Client identifier and channel for which \b PubNub client
 did fail to receive state stored inside \a 'error.associatedObject' in \b PNClient instance.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientStateRetrieveDidFailWithErrorNotification = @"PNClientStateRetrieveDidFailWithErrorNotification";

/**
 Sent when \b PubNub client successfully updated client state information.

 \b userInfo contains reference on \b PNClient instead of \b NSDictionary which hold information about client
 identifier, channel and resulting state itself (server will return final state state).
 */
static NSString * const kPNClientDidUpdateClientStateNotification = @"PNClientDidUpdateClientStateNotification";

/**
 Sent when \b PubNub client did fail to update client state information.

 \b userInfo contains \b PNError instead of \a NSDictionary. Client identifier and channel for which \b PubNub client
 did fail to update state stored inside \a 'error.associatedObject' in \b PNClient instance.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientStateUpdateDidFailWithErrorNotification = @"PNClientStateUpdateDidFailWithErrorNotification";

/**
 @brief Sent when \b PubNub client successfully started object synchronization with \b PubNub 
        cloud.
 
 @note \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
       hold information to identify remote object identifier and data location which has been
       synchronized with local copy (can be \c nil in case if whole object has been synchronized).
 
 @since <#version number#>
 */
static NSString * const kPNObjectSynchronizationDidStartNotification = @"PNObjectSynchronizationDidStartNotification";

/**
 @brief Sent when \b PubNub client did fail to start remote object synchronization with \b PubNub
        cloud.
 
 @note \b userInfo contains \b PNError instead of \a NSDictionary. Reference on object instance 
       for which \b PubNub client was unable to start synchronization object will be stored 
       inside of \b PNError's \a 'error.associatedObject' as \b PNObjectInformation instance.
 
 @since <#version number#>
 */
static NSString * const kPNObjectSynchronizationStartDidFailWithErrorNotification = @"PNObjectSynchronizationStartDidFailWithErrorNotification";

/**
 @brief Sent when \b PubNub client successfully stopped object synchronization with \b PubNub
        cloud.
 
 @note \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
       hold information to identify remote object identifier and data location which has been
       synchronized with local copy (can be \c nil in case if whole object has been synchronized).
 
 @since <#version number#>
 */
static NSString * const kPNObjectSynchronizationDidStopNotification = @"PNObjectSynchronizationDidStopNotification";

/**
 @brief Sent when \b PubNub client did fail to stop remote object synchronization with \b PubNub
        cloud.
 
 @note \b userInfo contains \b PNError instead of \a NSDictionary. \a 'error.associatedObject' 
       sotres reference on \b PNObjectInformation instance which allow to identify remote object
       and data path for which client was unable to stop synchronization process.
 
 @since <#version number#>
 */
static NSString * const kPNObjectSynchronizationStopDidFailWithErrorNotification = @"PNObjectSynchronizationStopDidFailWithErrorNotification";

/**
 @brief Sent when \b PubNub client received new remote data object modification event.

 @note \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
       hold information about object (under \c object property) which has been modified and list
       of data locations which has been changed).

 @since <#version number#>
 */
static NSString * const kPNObjectModificationEventNotification = @"PNObjectModificationEventNotification";

/**
 @brief Sent when \b PubNub client successfully retrieved data for remote data object from
        \b PubNub cloud.
 
 @note  \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
        hold information to identify remote data object and data location which has been 
        retrieved. Also this object has \c data property which represent data stored for object
        in \b PubNub cloud.
 
 @since <#version number#>
 */
static NSString * const kPNClientDidFetchObjectDataNotification = @"PNClientDidFetchObjectDataNotification";

/**
 @brief Sent when \b PubNub client did fail to retrieve remote object data from \b PubNub cloud.
 
 @note  \b userInfo contains \b PNError instead of \b NSDictionary. \a 'error.associatedObject'
        stores reference on \b PNObjectInformation which allow to identify which object client
        tried to fetch and reference on particular data location.
 
 @since <#version number#>
 */
static NSString * const kPNClientObjectDataFetchDidFailWithErrorNotification = @"PNClientObjectDataFetchDidFailWithErrorNotification";

/**
 @brief Sent when \b PubNub client successfully completed remote object data modification inside
        of \b PubNub cloud.
 
 @note  \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
        hold information to identify remote data object and data location which should be
        changed. Object has \c data property which represent data which should be used to modify
        object stored in \b PubNub cloud.
 
 @since <#version number#>
 */
static NSString * const kPNClientDidPushDataToObjectNotification = @"PNClientDidPushDataToObjectNotification";

/**
 @brief Sent when \b PubNub client did fail to modify remote object data inside of \b PubNub 
        cloud.
 
 @note  \b userInfo contains \b PNError instead of \b NSDictionary. \a 'error.associatedObject'
        stores reference on \b PNObjectInformation which allow to identify which object client
        tried to modify and reference on particular data location where data should be applied.
 
 @since <#version number#>
 */
static NSString * const kPNClientDataPushToObjectDidFailWithErrorNotification = @"PNClientDataPushToObjectDidFailWithErrorNotification";

/**
 @brief Sent when \b PubNub client successfully replaced piece of data with the one provided by
        user.
 
 @note  \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
        hold information to identify remote data object and data location which should be
        replaced. Object has \c data property which represent data which should be used to 
        replace existing data at specified location in \b PubNub cloud.
 
 @since <#version number#>
 */
static NSString * const kPNClientDidReplaceObjectDataNotification = @"PNClientDidReplaceObjectDataNotification";

/**
 @brief Sent when \b PubNub client did fail to replace data at specified location for remote data
        object stored in \b PubNub cloud.
 
 @note  \b userInfo contains \b PNError instead of \b NSDictionary. \a 'error.associatedObject'
        stores reference on \b PNObjectInformation which allow to identify for which object
        client tried to replace piece of data.
 
 @since <#version number#>
 */
static NSString * const kPNClientObjectDataReplaceDidFailWithErrorNotification = @"PNClientObjectDataReplaceDidFailWithErrorNotification";

/**
 @brief Sent when \b PubNub client successfully remove remote object's data at specified
        location inside of \b PubNub cloud.
 
 @note  \b userInfo contains reference on \b PNObjectInformation instead of \b NSDictionary which
        hold information to identify remote data object and data location which \b PubNub client
        tried to remove from \b PubNub cloud.
 
 @since <#version number#>
 */
static NSString * const kPNClientDidRemoveObjectDataNotification = @"PNClientDidRemoveObjectDataNotification";

/**
 @brief Sent when \b PubNub client did fail to remove object's data at specified location inside
        of \b PubNub cloud.
 
 @note  \b userInfo contains \b PNError instead of \b NSDictionary. \a 'error.associatedObject'
        stores reference on \b PNObjectInformation which allow to identify for which object
        client tried to remove piece of data.
 
 @since <#version number#>
 */
static NSString * const kPNClientObjectDataRemoveDidFailWithErrorNotification = @"PNClientObjectDataRemoveDidFailWithErrorNotification";

/**
 Sent when \b PubNub client was able to retrieve channel groups inside namespace or application wide.
 
 \b userInfo contains reference on \b PNChannelGroup instances stored in \a NSArray in case if request has been done for application wide
 or in \a NSDictionary in case if request for namespace and key under which list of groups is stored will be name of namespace.
 */
static NSString * const kPNClientChannelGroupsRequestCompleteNotification = @"PNClientChannelGroupsRequestCompleteNotification";

/**
 Sent when \b PubNub client did fail to retrieve channel groups inside namespace or application wide.
 
 \b userInfo contains \b PNError instead of \a NSDictionary. Namespace (if specified for request) will be stored inside 
 \a 'error.associatedObject'.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientChannelGroupsRequestDidFailWithErrorNotification = @"PNClientChannelGroupsRequestDidFailWithErrorNotification";

/**
 Sent when \b PubNub client was able to retrieve channels list for group.
 
 \b userInfo contains reference on \b PNChannelGroup instance which has channels proerty filled with channels received from server.
 */
static NSString * const kPNClientChannelsForGroupRequestCompleteNotification = @"PNClientChannelsForGroupRequestCompleteNotification";

/**
 Sent when \b PubNub client did fail to retrieve channels list for group.
 
 \b userInfo contains \b PNError instead of \a NSDictionary. \b PNChannelGroup instance will be stored inside
 \a 'error.associatedObject'.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientChannelsForGroupRequestDidFailWithErrorNotification = @"PNClientChannelsForGroupRequestDidFailWithErrorNotification";

/**
 Sent when \b PubNub client was able to add set of channels to the group.
 
 \b userInfo contains reference on \b PNChannelGroupChange instance which describe change action.
 */
static NSString * const kPNClientGroupChannelsAdditionCompleteNotification = @"PNClientGroupChannelsAdditionCompleteNotification";

/**
 Sent when \b PubNub client did fail to add channels to the group.
 
 \b userInfo contains \b PNError instead of \a NSDictionary. \b PNChannelGroupChange instance will be stored inside
 \a 'error.associatedObject'.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientGroupChannelsAdditionDidFailWithErrorNotification = @"PNClientGroupChannelsAdditionDidFailWithErrorNotification";

/**
 Sent when \b PubNub client was able to add set of channels to the group.
 
 \b userInfo contains reference on \b PNChannelGroupChange instance which describe change action.
 */
static NSString * const kPNClientGroupChannelsRemovalCompleteNotification = @"PNClientGroupChannelsRemovalCompleteNotification";

/**
 Sent when \b PubNub client did fail to remove channels from group.
 
 \b userInfo contains \b PNError instead of \a NSDictionary. \b PNChannelGroupChange instance will be stored inside
 \a 'error.associatedObject'.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientGroupChannelsRemovalDidFailWithErrorNotification = @"PNClientGroupChannelsRemovalDidFailWithErrorNotification";





/**
 Sent when \b PubNub client was able to receive list of namespaces registered under current subscription key.
 
 \b userInfo contains reference on \a NSArray instance with namespace names.
 */
static NSString * const kPNClientChannelGroupNamespacesRequestCompleteNotification = @"PNClientChannelGroupNamespacesRequestCompleteNotification";

/**
 Sent when \b PubNub client did fail to fetch list of namespaces.
 
 \b userInfo contains \b PNError instead of \a NSDictionary.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification = @"PNClientChannelGroupNamespacesRequestDidFailWithErrorNotification";

/**
 Sent when \b PubNub client was able to remove namespace along with channel groups which has been registered in it.
 
 \b userInfo contains reference on namespace name instead of \a NSDictionary.
 */
static NSString * const kPNClientChannelGroupNamespaceRemovalCompleteNotification = @"PNClientChannelGroupNamespaceRemovalCompleteNotification";

/**
 Sent when \b PubNub client did fail to remove namespace along with channel groups which has been registered in it.
 
 \b userInfo contains \b PNError instead of \a NSDictionary. Namespace name will be stored inside \a 'error.associatedObject'.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification = @"PNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification";

/**
 Sent when \b PubNub client was able to remove channel group along with all channels registered in it.
 
 \b userInfo contains reference on \b PNChannelGroup instance which describe target group.
 */
static NSString * const kPNClientChannelGroupRemovalCompleteNotification = @"PNClientChannelGroupRemovalCompleteNotification";

/**
 Sent when \b PubNub client did fail to remove channel group along with all channels registered in it.
 
 \b userInfo contains \b PNError instead of \a NSDictionary. \b PNChannelGroup instance will be stored inside
 \a 'error.associatedObject'.
 
 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientChannelGroupRemovalDidFailWithErrorNotification = @"PNClientChannelGroupRemovalDidFailWithErrorNotification";




/**
 Sent when \b PubNub client was able to complete subscription on specified set of channels.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances on which \b PubNub client was able to subscribe.
 */
static NSString * const kPNClientSubscriptionDidCompleteNotification = @"PNClientSubscriptionDidCompleteNotification";
static NSString * const kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification =
        @"PNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification";

/**
 Sent when \b PubNub client is about to restore subscription on specified set of channels. Mostly subscription
 restore happen after client recovery after network failure or \b PubNub client resuming after suspension
 (application has been sent to background execution context).

 \b userInfo contains reference on \a NSArray of \b PNChannel instances on which \b PubNub client will restore
 subscription.
 */
static NSString * const kPNClientSubscriptionWillRestoreNotification = @"PNClientSubscriptionWillRestoreNotification";

/**
 Sent when \b PubNub client complete subscription restore process on specified set of channels. Mostly subscription
 restore happen after client recovery after network failure or \b PubNub client resuming after suspension
 (application has been sent to background execution context).

 \b userInfo contains reference on \a NSArray of \b PNChannel instances on which \b PubNub client did restore
 subscription.
 */
static NSString * const kPNClientSubscriptionDidRestoreNotification = @"PNClientSubscriptionDidRestoreNotification";

/**
 Sent when \b PubNub client was unable to subscribe / restore subscription on specified set of channels.

 \b userInfo contains \b PNError instead of \a NSDictionary. Set of channels on which \b PubNub client did fail to
 subscribe stored inside \a 'error.associatedObject' as \a NSArray of \b PNChannel instances.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientSubscriptionDidFailNotification = @"PNClientSubscriptionDidFailNotification";
static NSString * const kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification = @"PNClientSubscriptionDidFailOnClientIdentifierUpdateNotification";

/**
 Sent when \b PubNub client did complete unsubscription process for specified set of channels.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances from which \b PubNub client did unsubscribe.
 */
static NSString * const kPNClientUnsubscriptionDidCompleteNotification = @"PNClientUnsubscriptionDidCompleteNotification";
static NSString * const kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification = @"PNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification";

/**
 Sent when \b PubNub client did fail to unsubscribe from specified set of channels.

 \b userInfo contains \b PNError instead of \a NSDictionary. Set of channels from which \b PubNub client did fail to
 unsubscribe stored inside \a 'error.associatedObject' as \a NSArray of \b PNChannel instances.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientUnsubscriptionDidFailNotification = @"PNClientUnsubscriptionDidFailNotification";
static NSString * const kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification = @"PNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification";

/**
 * Sent when \b PubNub client did complete presence enabling process on specified set of channels.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances for which \b PubNub client did enable presence.
 */
static NSString * const kPNClientPresenceEnablingDidCompleteNotification = @"PNClientPresenceEnablingDidCompleteNotification";

/**
 Sent when \b PubNub client did fail to enable presence on specified set of channels.

 \b userInfo contains \b PNError instead of \a NSDictionary. Set of channels from which \b PubNub client did fail to
 enable presence stored inside \a 'error.associatedObject' as \a NSArray of \b PNChannel instances.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientPresenceEnablingDidFailNotification = @"PNClientPresenceEnablingDidFailNotification";

/**
 Sent when \b Pubnub client did complete presence disabling process on specified set of channels.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances for which \b PubNub client did disable presence.
 */
static NSString * const kPNClientPresenceDisablingDidCompleteNotification = @"PNClientPresenceDisablingDidCompleteNotification";

/**
 Sent when \b PubNub client did fail to disable presence on specified set of channels.

 \b userInfo contains \b PNError instead of \a NSDictionary. Set of channels from which \b PubNub client did fail to
 disable presence stored inside \a 'error.associatedObject' as \a NSArray of \b PNChannel instances.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientPresenceDisablingDidFailNotification = @"PNClientPresenceDisablingDidFailNotification";

/**
 Sent when \b PubNub client did complete messages observation and notification via Apple Push Notification enabling on
 specified set of channels.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances for which \b PubNub client did enable
 messages observation via Apple Push Notifications.
 */
static NSString * const kPNClientPushNotificationEnableDidCompleteNotification = @"PNClientPushNotificationEnableDidCompleteNotification";

/**
 Sent when \b PubNub client did fail to enable messages observation and notification via Apple Push Notification on
 specified set of channels.

 \b userInfo contains \b PNError instead of \a NSDictionary. Set of channels from which \b PubNub client did fail to
 enable messages observation via Apple Push Notifications stored inside \a 'error.associatedObject' as \a NSArray of
 \b PNChannel instances.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientPushNotificationEnableDidFailNotification = @"PNClientPushNotificationEnableDidFailNotification";

/**
 Sent when \b PubNub client did complete messages observation and notification via Apple Push Notification disabling on
 specified set of channels.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances for which \b PubNub client did disable messages
 observation via Apple Push Notifications.
 */
static NSString * const kPNClientPushNotificationDisableDidCompleteNotification = @"PNClientPushNotificationDisableDidCompleteNotification";

/**
 Sent when \b PubNub client did fail to disable messages observation and notification via Apple Push Notification on
 specified set of channels.

 \b userInfo contains \b PNError instead of \a NSDictionary. Set of channels from which \b PubNub client did fail to
 disable messages observation via Apple Push Notifications stored inside \a 'error.associatedObject' as \a NSArray of
 \b PNChannel instances.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientPushNotificationDisableDidFailNotification = @"PNClientPushNotificationDisableDidFailNotification";

/**
 Sent when \b PubNub client did complete messages observation removal from all channels which has been previously
 enabled.
 */
static NSString * const kPNClientPushNotificationRemoveDidCompleteNotification = @"PNClientPushNotificationRemoveDidCompleteNotification";

/**
 Sent when \b PubNub client did fail messages observation removal from all channels which has been previously
 enabled.

 \b userInfo contains \b PNError instead of \a NSDictionary.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientPushNotificationRemoveDidFailNotification = @"PNClientPushNotificationRemoveDidFailNotification";

/**
 Sent when \b PubNub client did complete message observation enabled channels retrieval process.

 \b userInfo contains reference on \a NSArray of \b PNChannel instances on which message observation via Apple Push
 Notifications is enabled.
 */
static NSString * const kPNClientPushNotificationChannelsRetrieveDidCompleteNotification = @"PNClientPushNotificationChannelsRetrieveDidCompleteNotification";

/**
 Sent when \b PubNub client did fail to retrieve message observation enabled channels.

 \b userInfo contains \b PNError instead of \a NSDictionary.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientPushNotificationChannelsRetrieveDidFailNotification = @"PNClientPushNotificationChannelsRetrieveDidFailNotification";

/**
 Sent when \b PubNub client did complete access rights change process.

 \b userInfo contains reference on \b PNAccessRightsCollection which aggregate in itself \b PNAccessRightsInformation
 instances to describe access rights at different levels (there is a three levels: application, channel and user).
 */
static NSString * const kPNClientAccessRightsChangeDidCompleteNotification = @"PNClientAccessRightsChangeDidCompleteNotification";

/**
 Sent when \b PubNub client did fail access rights change.

 \b userInfo contains \b PNError instead of \a NSDictionary. \a 'error.associatedObject' stores reference on
 \b PNAccessRightOptions instance which describes what kind of access right change manipulation and at which
 level failed.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientAccessRightsChangeDidFailNotification = @"PNClientAccessRightsChangeDidFailNotification";

/**
 Sent when \b PubNub client did complete access rights audit process.

 \b userInfo contains reference on \b PNAccessRightsCollection which aggregate in itself \b PNAccessRightsInformation
 instances to describe access rights at different levels (there is a three levels: application, channel and user).
 */
static NSString * const kPNClientAccessRightsAuditDidCompleteNotification = @"PNClientAccessRightsAuditDidCompleteNotification";

/**
 Sent when \b PubNub client did fail access rights audition.

 \b userInfo contains reference on \b PNError instead of \a NSDictionary. \a 'error.associatedObject' stores reference on
 \b PNAccessRightOptions instance which describes access level for which audition has been requested.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientAccessRightsAuditDidFailNotification = @"PNClientAccessRightsAuditDidFailNotification";

/**
 Sent when \b PubNub client did complete time token retrieval process.

 \b userInfo contains reference on \a NSNumber with unsigned long time token instead of \a NSDictionary.
 */
static NSString * const kPNClientDidReceiveTimeTokenNotification = @"PNClientDidReceiveTimeTokenNotification";

/**
 Sent when \b PubNub client did fail to retrieve time token.

 \b userInfo contains \b PNError instead of \a NSDictionary.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientDidFailTimeTokenReceiveNotification = @"PNClientDidFailTimeTokenReceiveNotification";

/**
 Sent when \b PubNub client will start message sending into specified channel.

 \b userInfo contains \b PNMessage instead of \a NSDictionary. \b PNMessage instance describes message which should
 be sent and into which channel.
 */
static NSString * const kPNClientWillSendMessageNotification = @"PNClientWillSendMessageNotification";

/**
 Sent when \b PubNub client did sent message into specified channel.

 \b userInfo contains \b PNMessage instead of \a NSDictionary. \b PNMessage instance describes message which has been
 sent and into which channel.
 */
static NSString * const kPNClientDidSendMessageNotification = @"PNClientDidSendMessageNotification";

/**
 Senr when \b PubNub client did fail to send message into specified channel.

 \b userInfo contains \b PNError instead of \a NSDictionary. \b PNMessage which \b PubNub client did fail to
 send stored inside \a 'error.associatedObject' as \b PNMessage instance. \b PNMessage instance describes message which should
 be sent and into which channel.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientMessageSendingDidFailNotification = @"PNClientMessageSendingDidFailNotification";

/**
 Sent when \b PubNub client did receive message from channel on which it is subscribed.

 \b userInfo contains \b PNMessage instead of \a NSDictionary. \b PNMessage instance contains message which has been
 received from channel (along with channel information).
 */
static NSString * const kPNClientDidReceiveMessageNotification = @"PNClientDidReceiveMessageNotification";

/**
 Sent when \b PubNub client did receive presence event on channel (\a 'join' / \a 'leave' / \a 'timeout' events).

 \b userInfo contains \b PNPresenceEvent instead of \a NSDictionary. \b PNPresenceEvent instance describes what kind
 of event and by who has been generated on specific channel.
 */
static NSString * const kPNClientDidReceivePresenceEventNotification = @"PNClientDidReceivePresenceEventNotification";

/**
 Sent when \b PubNub client did complete history retrieval process for specific channel and parameters set.

 \b userInfo contains \b PNMessageHistory instead of \a NSDictionary. \b PNMessageHistory instance contains set of
 messages which has been received at specific channel in specified time window.
 */
static NSString * const kPNClientDidReceiveMessagesHistoryNotification = @"PNClientDidReceiveMessagesHistoryNotification";

/**
 Sent when \b PubNub client did fail history retrieval process.

 \b userInfo contains \b PNError instead of \a NSDictionary. \b PNChannel for which \b PubNub client did fail to
 receive history stored inside \a 'error.associatedObject'.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientHistoryDownloadFailedWithErrorNotification = @"PNClientHistoryDownloadFailedWithErrorNotification";

/**
 Sent when \b PubNub client did complete participants list retrieval process.

 \b userInfo contains \b PNHereNow instead of \a NSDictionary. \b PNHereNow instance contain methods which allow to 
 get list of channels for which information available and get participants list for each of those channels.
 */
static NSString * const kPNClientDidReceiveParticipantsListNotification = @"PNClientDidReceiveParticipantsListNotification";

/**
 Sent when \b PubNub client did fail to retrieve participants list for specific channel.

 \b userInfo contains \b PNError instead of \a NSDictionary. List of \b PNChannel and \b PNChannelGroup for which 
 \b PubNub client did fail to receive participants list stored inside \a 'error.associatedObject'.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientParticipantsListDownloadFailedWithErrorNotification=@"PNClientParticipantsListDownloadFailedWithErrorNotification";

/**
 Sent when \b PubNub client did complete participant channels list retrieval process.

 \b userInfo contains \b PNWhereNow instead of \a NSDictionary. \b PNWhereNow instance contain set of \b PNChannel
 instances and client identifier (for which this request has been made).
 */
static NSString * const kPNClientDidReceiveParticipantChannelsListNotification = @"PNClientDidReceiveParticipantChannelsListNotification";

/**
 Sent when \b PubNub client did fail to retrieve participant channels list for specific identifier.

 \b userInfo contains \b PNError instead of \a NSDictionary. Client identifier for which \b PubNub client did fail to
 receive participant channels list stored inside \a 'error.associatedObject'.

 @note Always check \a error.code to find out what caused error (check PNErrorCodes header file and use \a -localizedDescription /
 \a -localizedFailureReason and \a -localizedRecoverySuggestion to get human readable description for error).
 */
static NSString * const kPNClientParticipantChannelsListDownloadFailedWithErrorNotification = @"PNClientParticipantChannelsListDownloadFailedWithErrorNotification";

#endif
