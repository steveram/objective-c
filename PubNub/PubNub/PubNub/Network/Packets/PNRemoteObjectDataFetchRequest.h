#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNObjectInformation;

/**
 @brief      Request which allow to pull out data stored in \b PubNub cloud for concrete remote
             object.
 
 @discussion Depending on specified parameters for object request can pull out whole object's 
             data or piece if path has been specified.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNRemoteObjectDataFetchRequest : PNBaseRequest


#pragma mark - Class methods

/**
 @brief Construct reuqest which allow to fetch whole or partial remote object data from \b PubNub
        cloud.
 
 @param objectInformation Reference on instance which temporary describes remote object and has
                          all required fetch options to retrieve object's data from \b PubNub
                          cloud.
 
 @return Ready to use request remote object fetch request.
 
 @since <#version number#>
 */
+ (instancetype)remoteObjectFetchRequestFor:(PNObjectInformation *)objectInformation;


#pragma mark - Instance methods

/**
 @brief Initialize reuqest which allow to fetch whole or partial remote object data from 
        \b PubNub cloud.
 
 @param objectInformation Reference on instance which temporary describes remote object and has
                          all required fetch options to retrieve object's data from \b PubNub
                          cloud.
 
 @return Ready to use request remote object fetch request.
 
 @since <#version number#>
 */
- (instancetype)initRequestFor:(PNObjectInformation *)objectInformation;

#pragma mark -


@end
