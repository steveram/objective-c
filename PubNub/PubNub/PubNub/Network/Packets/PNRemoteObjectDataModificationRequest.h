#import "PNBaseRequest.h"


#pragma mark - Class forward

@class PNObjectInformation;


/**
 @brief Request which allow client to alter data of object stored in \b PubNub cloud.
 
 @discussion At this moment \b PubNub client support data: push, replace and delete operation.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface PNRemoteObjectDataModificationRequest : PNBaseRequest


#pragma mark - Properties

/**
 @brief Stores reference on instance which temporary represent remote object with all information
        required to complete manipulation request.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) PNObjectInformation *objectInformation;

/**
 @brief Stores reference on key which is used durng new entries addition for 
        \c PNPushToListModificationType operation and help \b PubNub client define order in which
        entries will be returned to the client on fetch.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *entriesSortingKey;


#pragma mark - Class methods

/**
 @brief Construct request which will allow to push new/rewrite portion of data in target remote
        object in \b PubNub cloud.
 
 @param objectInformation Reference on instance which temporary describes remote object and has
                          all required data to update object's data in \b PubNub cloud.
 
 @return Ready to use request remote object data push request.
 
 @since <#version number#>
 */
+ (instancetype)dataPushRequestFor:(PNObjectInformation *)objectInformation;

/**
 @brief Construct request which will allow to push data to the list in target remote object in 
        \b PubNub cloud.
 
 @param objectInformation Reference on instance which temporary describes remote object and has
                          all required data to update object's data in \b PubNub cloud.
 @param entriesSortingKey Allow to manage lexigraphical sorting mechanism by specifying char or
                          word with which will be used during output of sorted list. Only
                          \b [A-Za-z] can be used.
                          If \c nil is passed, then object(s) will be added to the end of the 
                          list.
 
 @return Ready to use request remote object data push to list request.
 
 @since <#version number#>
 */
+ (instancetype)dataPushToListRequestFor:(PNObjectInformation *)objectInformation
                          withSortingKey:(NSString *)entriesSortingKey;

/**
 @brief Construct request which will allow to replace piece of data target remote object in 
        \b PubNub cloud.
 
 @param objectInformation Reference on instance which temporary describes remote object and has
                          all required data to replace piece of object's data in \b PubNub cloud.
 
 @return Ready to use request remote object data replace request.
 
 @since <#version number#>
 */
+ (instancetype)dataReplaceRequestFor:(PNObjectInformation *)objectInformation;

/**
 @brief Construct request which will allow to remove piece of data target remote object in
        \b PubNub cloud.
 
 @param objectInformation Reference on instance which temporary describes remote object and has
                          all required data to remove piece of object's data in \b PubNub cloud.
 
 @return Ready to use request remote object data remove request.
 
 @since <#version number#>
 */
+ (instancetype)dataRemoveRequestFor:(PNObjectInformation *)objectInformation;


#pragma mark -

@end
