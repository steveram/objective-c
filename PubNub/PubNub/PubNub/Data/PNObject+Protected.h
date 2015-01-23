/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNObject.h"


#pragma mark Private interface declaration

@interface PNObject ()

#pragma mark - Properties

@property (nonatomic, assign, getter = isValid) BOOL valid;

/**
 @brief Stores reference to the cache where actual object data is stored.
 
 @since <#version number#>
 */
@property (nonatomic, strong) id data;


#pragma mark - Instance methods

/**
 @brief Mark object as invalid and destroy any reference on cached object data.
 
 @since <#version number#>
 */
- (void)invalidate;

#pragma mark -

@end
