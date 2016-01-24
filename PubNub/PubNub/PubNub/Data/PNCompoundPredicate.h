#import "PNPredicate.h"

NS_ASSUME_NONNULL_BEGIN


#pragma mark Types

/**
 @brief  List of predicates combination types which can be used during compound filter 
         predicate construction.
 */
typedef NS_ENUM(NSUInteger, PNPredicateCompoundType) {
    
    /**
     @brief  Predicates combined with \c AND logic operation.
     */
    PNAndPredicateCompoundType,
    
    /**
     @brief  Predicates combined with \c OR logic operation.
     */
    PNOrPredicateCompoundType,
    
    /**
     @brief  Passed predicate will negate it's evaluation result.
     */
    PNNotPredicateCompoundType
};


/**
 @brief      Evaluate few comparison predicates joined with logical \c "gate" operations 
             (AND/OR/NOT).
 @discussion Using this class few comparison predicates can be joined together using logical 
             operations at the moment of evaluation. It is also possible to negate single predicate
             using \c NOT operation.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNCompoundPredicate : PNPredicate


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores one of \c PNPredicateCompoundType enum fiels which allow to 
         identify how predicates joined logically inside.
 */
@property (readonly, assign) PNPredicateCompoundType compoundPredicateType;

/**
 @brief  Stores reference on list of predicates which should be joined logically.
 */
@property (readonly, strong) NSArray *subpredicates;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Create and configure predicate which join passed predicates with \b AND.
 @discussion \b Example:
 @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.health"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@358];
PNComparisonPredicate *leftPerdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                          rightExpression:rightExpression
                                                                                     type:PNComparisonLessThanType];
leftExpression = [PNExpression expressionForKeyPath:@"player['level']"];
rightExpression = [PNExpression expressionForConstantValue:@85];
PNComparisonPredicate *rightPerdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                           rightExpression:rightExpression
                                                                                      type:PNComparisonLessThanOrEqualType];
PNCompoundPredicate *predicate = [PNCompoundPredicate andPredicateWithSubpredicates:@[leftPerdicate, rightPerdicate]];
[self.client setFilterExpression:predicate];
 @endcode
 In example above only messages which will arrive to channel will be those for which both predicates
 will evaluate to \c true.
 
 @param subpredicates List of predicates which should be joined by logical \c AND.
 
 @return Configured and ready to use compound predicate.
 */
+ (instancetype)andPredicateWithSubpredicates:(NSArray<PNPredicate *> *)subpredicates;

/**
 @brief      Create and configure predicate which join passed predicates with \b OR.
 @discussion \b Example:
 @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.health"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@358];
PNComparisonPredicate *leftPerdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                          rightExpression:rightExpression
                                                                                     type:PNComparisonLessThanType];
leftExpression = [PNExpression expressionForKeyPath:@"player['level']"];
rightExpression = [PNExpression expressionForConstantValue:@85];
PNComparisonPredicate *rightPerdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                           rightExpression:rightExpression
                                                                                      type:PNComparisonLessThanOrEqualType];
PNCompoundPredicate *predicate = [PNCompoundPredicate orPredicateWithSubpredicates:@[leftPerdicate, rightPerdicate]];
[self.client setFilterExpression:predicate];
 @endcode
 In example above only messages which will arrive to channel will be those for which any of predicates
 will evaluate to \c true.
 
 @param subpredicates List of predicates which should be joined by logical \c OR.
 
 @return Configured and ready to use compound predicate.
 */
+ (instancetype)orPredicateWithSubpredicates:(NSArray<PNPredicate *> *)subpredicates;

/**
 @brief      Create and configure negate compoun predicate which will evaluate to \c true
             in case if \c predicate will evaluate to \c false.
 @discussion \b Example:
 @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.health"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@358];
PNComparisonPredicate *comparePerdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                             rightExpression:rightExpression
                                                                                        type:PNComparisonLessThanType];
PNCompoundPredicate *predicate = [PNCompoundPredicate notPredicateWithSubpredicate:comparePerdicate];
[self.client setFilterExpression:predicate];
 @endcode
 In example above only messages which will arrive to channel will be those for which \c comparePerdicate
 will evaluate to \c false.
 
 @param predicate Reference on predicate which should be negated.
 
 @return Configured and ready to use compound predicate.
 */
+ (instancetype)notPredicateWithSubpredicate:(PNPredicate *)predicate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
