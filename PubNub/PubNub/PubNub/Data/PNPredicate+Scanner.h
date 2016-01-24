#import "PNPredicate.h"


/**
 @brief      Filter predicate extension to parse user-provided predicate expression.
 @discussion Scanner analyze and extract separate predicates from user-provided format
             string.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNPredicate (Scanner)


///------------------------------------------------
/// @name Translation
///------------------------------------------------

/**
 @brief  Translate user provided filter expression to \b PNPredicate instance(s).
 
 @return Initialized and ready to use \b PNPredicate instance.
 */
- (instancetype)predicate;

#pragma mark -


@end
