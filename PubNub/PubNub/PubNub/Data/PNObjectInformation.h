#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNObject;


/**
 @brief      Represent parameters which is used to get access to whole remote object stored in
             \b PubNub cloud or on it's piece (if specified location key-path).
 
 @discussion This object is used along with remote object manipulation API and returned as part
             of error object to make it easy to understand what exact object client tried to 
             receive.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface PNObjectInformation : NSObject


#pragma mark - Properties

/**
 @brief Stores reference on remote object identifier which should be fetched from \b PubNub
        cloud.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 @brief Stores reference on remote object's pieces of data which should be fetched from \b PubNub
        cloud.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) NSArray *dataLocations;

/**
 @brief Stores reference on object which it represent.
 
 @discussion This property can be set by \b PubNub synchronization manager at the end of 
             synchronization process.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) PNObject *object;

/**
 @brief Temporary stores data which should be used for manipulation on remote data object or
        received from \b PubNub cloud on request.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) id data;

#pragma mark -


@end
