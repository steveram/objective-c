#import "PNPredicate.h"


#pragma mark Class forward

@class PNExpression;


/**
 @brief      Evaluate operation expression into predicate.
 @discussion Allow to represent operation groups with grouping predicate.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNOperationPredicate : PNPredicate


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on math operation expression.
 */
@property (readonly, strong) PNExpression *expression;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct and configure predicate using operation expression.
 
 @param expression Representation of mathematic operation which should be wrapped
                   into predicate.
 
 @return Configured and ready to use predicate instance.
 */
+ (instancetype)operationPredicateWithExpression:(PNExpression *)expression;


///------------------------------------------------
/// @name Translation
///------------------------------------------------

/**
 @brief  Translate user-specified comparision details to string w/o enclosing result
         into parenthesis.
 
 @return Stringified comparision / logical operation.
 */
- (NSString *)stringValueWithOutParenthesis;

/**
 @brief  Translate user-specified comparision details to string w/o enclosing result
         into parenthesis.
 
 @param encloseInParenthesis Whether string representation should be enclosed into
                             parenthesis or not.
 
 @return Stringified comparision / logical operation.
 */
- (NSString *)stringValueWithParenthesis:(BOOL)encloseInParenthesis;

#pragma mark - 


@end
