#import <Foundation/Foundation.h>
#import "PNChannelProtocol.h"


/**
 @brief      Class used to represent locally object which is stored in \b PubNub cloud.
 
 @discussion \b PubNub cloud store objects using their unique name (like root folder name). All
             data stored internally at key paths as simple values or collections.
 
 @note       This instance doesn't own cached data and it can be invalidated any moment in case
             if cache will purge object from local storage (it may happen in case of 
             synchronization termination for example).
 
 @warning    If object has been provided by synchronization API and been invalidated, it also 
             mean that the only reference on object which is left is your code (which may store
             is somewhere in property).
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface PNObject : NSObject <PNChannelProtocol>


#pragma mark - Properties

/**
 @brief      Stores reference on identifier of remote data object which is stored in \b PubNub 
             cloud.
 
 @discussion This is base information which is required to identify scope of data which this 
             object may represent locally (if this object instance has been received from 
             synchronization callback).
 
 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 @brief      Stores whether instance data stores valid remote object information or not.
 
 @discussion This object also can be invalid in case if it has been created manually for usage 
             with other API. In case if object synchronization not completed or has been stopped
             this object will be invalid as well.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, assign, getter = isValid) BOOL valid;


#pragma mark - Class methods

/**
 @brief      Create dummy object instance which not bound to any synchronization schemes.
 
 @discussion This method is useful when object should be passed to one of APIs (PAM for example).
 
 @param identifier Reference on identifier which has been used to store object in \b PubNub cloud
                   and allow to gain access to it and synchronize with local copy.
 
 @return Created and ready to use dummy object with specified identifier.
 
 @since <#version number#>
 */
+ (instancetype)objectWithIdentifier:(NSString *)identifier;

/**
 @brief      Create list of dummy object instances which not bound to any synchronization 
             schemes.
 
 @discussion This method is useful when object should be passed to one of APIs (PAM for example).
 
 @param identifiers List of identifiers from objects stored in \b PubNub cloud.
 
 @return List of created ready to use dummy objects whith specified identifiers.
 
 @since <#version number#>
 */
+ (NSArray *)objectsWithIdentifiers:(NSArray *)identifiers;

#pragma mark -


@end
