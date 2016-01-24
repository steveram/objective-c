#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 @brief      Class describe real-time messages filtering predicate.
 @discussion Predicate allow to instruct client about which messages should be received from 
             \b PubNub service.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNPredicate : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Create and configure filter predicate instance using user-defined format.
 @discussion Predicate use provided format to evaluate it against published message \b meta 
             dictionary to identify whether message should be delivered to the client or not.
 @warning    Format should be defined in a way which will produce \b bool evalutation result. If 
             wrong format has been passed \b exception will be thrown.
 @discussion \b Example:
 @code
PNPredicate *predicate = [PNPredicate predicateWithFormat:@"string IN %@", @[@"'a'",@"'b'",@"'c'"], nil];
 @endcode
 
 @param format Format which describes comparison operation between few expressions.
 @param ...    List of arguments with which tokens in \c format should be substituted. \c nil can be
               passed as well. \b Warning: all passed elements should be objects (subclasses of
               \b NSObject).
 
 @return Configured and ready to use instance (if no exception will be thrown).
 */
+ (instancetype)predicateWithFormat:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;

/**
 @brief      Create and configure filter predicate instance using user-defined format.
 @discussion Predicate use provided format to evaluate it against published message \b meta 
             dictionary to identify whether message should be delivered to the client or not.
 @warning    Format should be defined in a way which will produce \b bool evalutation result. If 
             wrong format has been passed \b exception will be thrown.
 @discussion \b Example:
 @code
PNPredicate *predicate = [PNPredicate predicateWithFormat:@"string IN %@" 
                                            argumentArray:@[@"'a'",@"'b'",@"'c'"]];
 @endcode
 
 @param format    Format which describes comparison operation between few expressions.
 @param arguments List of arguments with which tokens in \c format should be substituted. \c nil can
                  be passed as well.
 
 @return Configured and ready to use instance (if no exception will be thrown).
 */
+ (PNPredicate *)predicateWithFormat:(NSString *)format argumentArray:(nullable NSArray *)arguments;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
