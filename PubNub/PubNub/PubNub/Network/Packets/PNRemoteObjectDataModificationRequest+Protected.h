/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNRemoteObjectDataModificationRequest.h"


#pragma mark - Types & Structures

typedef NS_OPTIONS(NSUInteger, PNRemoteObjectModificationType)  {
    
    PNRemoteObjectPushModificationType,
    PNRemoteObjectPushToListModificationType,
    PNRemoteObjectReplaceModificationType,
    PNRemoteObjectRemoveModificationType
};


#pragma mark - Class forward

@class PNObjectInformation;


#pragma mark - Private interface declaration

@interface PNRemoteObjectDataModificationRequest ()


#pragma mark - Properties

@property (nonatomic, strong) PNObjectInformation *objectInformation;

/**
 @brief Stores reference on marker which tell what exact type of modification will be performed.
 
 @since <#version number#>
 */
@property (nonatomic, assign) PNRemoteObjectModificationType modificationType;

@property (nonatomic, copy) NSString *entriesSortingKey;

/**
 @brief Stores reference on data which has been pre-processed and ready to be sent to \b PubNub
        cloud
 
 @since <#version number#>
 */
@property (nonatomic, strong) NSString *preparedData;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *publishKey;


#pragma mark - Instance methods

/**
 @brief Initiate request for remote object data modification.
 
 @param modificationType  Instance which temporary represent remote data object information and
                          stores all data required for modificaiton.
 @param objectInformation Reference on actual modification type.
 
 @return Initiated and ready to use remote object modification request.
 
 @since <#version number#>
 */
- (instancetype)initModificationRequest:(PNRemoteObjectModificationType)modificationType
                              forObject:(PNObjectInformation *)objectInformation;

#pragma mark -


@end
