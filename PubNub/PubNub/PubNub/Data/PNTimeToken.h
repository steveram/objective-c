#import <Foundation/Foundation.h>


/**
 @brief      Class describe service time token.
 @discussion Aside from high precision time token service provide region identifer as well to 
             complete time token description related to region.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNTimeToken : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on unixtimestamp with high precision.
 
 @since 3.8.0
 */
@property (nonatomic, readonly, copy) NSNumber *token;

/**
 @brief  Stores reference on \b PubNub server region identifier (which generated \c token value).
 */
@property (nonatomic, readonly, copy) NSNumber *region;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct and configure time token instance.
 
 @param token  Unixtimestamp with high precision.
 @param region \b PubNub server region identifier (which generated \c token value).
 
 @return Configured and ready to use time token information instance.
 
 @since 3.8.0
 */
+ (instancetype)timeTokenWithTime:(NSString *)token andRegion:(NSNumber *)region;

#pragma mark -


@end
