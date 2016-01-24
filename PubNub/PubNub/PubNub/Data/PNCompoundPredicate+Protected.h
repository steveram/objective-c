/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNCompoundPredicate.h"


#pragma mark Private interface declaration

@interface PNCompoundPredicate ()


#pragma mark - Properties

@property (assign) PNPredicateCompoundType compoundPredicateType;
@property (strong) NSArray *subpredicates;


#pragma mark - Initialization and Configuration

/**
 @brief  Create and configure predicate which join passed predicates with \b AND.
 
 @param type          One of \c PNPredicateCompoundType enum fiels which allow to 
                      identify how predicates joined logically inside.
 @param subpredicates List of predicates which should be joined by logical \c AND.
 
 @return Configured and ready to use compound predicate.
 */
- (instancetype)initWithCompoundType:(PNPredicateCompoundType)type 
                       subpredicates:(NSArray<PNPredicate *> *)subpredicates;


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
