/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRemoteObjectDataFetchRequest.h"

#pragma mark Class forward

@class PNObjectInformation;


#pragma mark - Private interface declaration

@interface PNRemoteObjectDataFetchRequest ()


#pragma mark - Properties

/**
 @brief Stores reference on instance which temporary describes remote data object stored in 
        \b PubNub cloud.
 
 @since <#version number#>
 */
@property (nonatomic, strong) PNObjectInformation *objectInformation;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
