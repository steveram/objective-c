#import "PNPredicate.h"


#pragma mark Types

/**
 @brief  List of types which can be used during filter predicate construction.
 */
typedef NS_ENUM(NSUInteger, PNComparisonOperatorType) {
    
    /**
     @brief      Check whether left hand expression evaluate to value smaller than right hand
                 expression.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.health"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@358];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonLessThanType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     health field store value smaller than \c 358.
     */
    PNComparisonLessThanType,
    
    /**
     @brief      Check whether left hand expression evaluate to value smaller than or equal to right 
                 hand expression.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player['level']"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@85];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonLessThanOrEqualType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     level field store value smaller than or equal to \c 85.
     */
    PNComparisonLessThanOrEqualType,
    
    /**
     @brief      Check whether left hand and right hand expression evaluate to same values.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player['level']"];
PNExpression *rightExpression = [PNExpression expressionForKeyPath:@"weapon.level"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonEqualToType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     level field store value equal to weapon's minimum required level.
     */
    PNComparisonEqualToType,
    
    /**
     @brief      Check whether left hand and right hand expression evaluate to different values.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.admin"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@NO];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonNotEqualToType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     admin priority field store value which is not to \c YES.
     */
    PNComparisonNotEqualToType,
    
    /**
     @brief      Check whether left hand expression evaluate to value larger than right hand
                 expression.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.level"];
PNExpression *rightExpression = [PNExpression expressionForKeyPath:@"world.chat['hero']"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonGreaterThanType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     level field store value which is greater than value stored for "world" chat for "heroes".
     */
    PNComparisonGreaterThanType,
    
    /**
     @brief      Check whether left hand expression evaluate to value larger than or equal to right 
                 hand expression.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.level"];
PNExpression *rightExpression = [PNExpression expressionForKeyPath:@"dungeon.level"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonGreaterThanOrEqualToType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     level field store value which is greater than or equal to value stored for dungeon minimum player level.
     */
    PNComparisonGreaterThanOrEqualToType,
    
    /**
     @brief      Allow to check whether left hand expression stores value which is equal to the string
                 defined in right hand expression.
     @discussion This comparison operator allow to use Apple's \c * and SQL \c % tokens to search for
                 partial equality in values. 
     @discussion \b Important: left hand expression can be: \c string, \c array or \c dictionary. For 
                 collections comparison operator work against values (in case of dictionary against of values
                 stored under keys). This operator is \b case-insensitive with evaluated values.
     @discussion \b Warning: tokens can be placed at the beginning/ending or both of string represented in
                 right hand expression.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.skills"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@"*stun%"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonLikeType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     skills field store array of skills where any of them has name which contain \b stun at any part of it.
     */
    PNComparisonLikeType,
    
    /**
     @brief      This is shortcut version of \b PNComparisonLikeType which allow to pass messages where
                 value stored in left hand expression starts with string specified in right hand expression.
     @discussion This comparison operator allow to use Apple's \c * and SQL \c % tokens to search for
                 partial equality in values. 
     @discussion \b Important: left hand expression can be: \c string, \c array or \c dictionary. For 
                 collections comparison operator work against values (in case of dictionary against of values
                 stored under keys). This operator is \b case-insensitive with evaluated values.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.skills"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@"Lightning"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonBeginsWithType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     skills field store array of skills where any of them has name which starts with \b Lightning.
     */
    PNComparisonBeginsWithType,
    
    /**
     @brief      This is shortcut version of \b PNComparisonLikeType which allow to pass messages where
                 value stored in left hand expression ends with string specified in right hand expression.
     @discussion This comparison operator allow to use Apple's \c * and SQL \c % tokens to search for
                 partial equality in values. 
     @discussion \b Important: left hand expression can be: \c string, \c array or \c dictionary. For 
                 collections comparison operator work against values (in case of dictionary against of values
                 stored under keys). This operator is \b case-insensitive with evaluated values.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"player.skills"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@"boost"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonBeginsWithType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata player's
     skills field store array of skills where any of them has name which ends with \b boost.
     */
    PNComparisonEndsWithType,
    
    /**
     @brief      This comparison allow to check whether value represented by left hand expression is present
                 in value represented by right hand expression.
     @discussion \b Important: left hand expression can be: \c string or \c number. Right hand expression 
                 can be: \c string, \c array or \c dictionary. For collections comparison operator work against
                 keys/values (in case of dictionary against of keys). This operator is \b case-sensitive with
                 evaluated values.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"weapon['id']"];
PNExpression *rightExpression = [PNExpression expressionForKeyPath:@"world.weapon['rare']"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonBeginsWithType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata weapon's
     id field store value which is present in world's rare items list. World's item list can be array or ictionary
     where each key is item id (evaluation with dictionaries performed against keys).
     */
    PNComparisonInType,
    
    /**
     @brief      This is shortcut version of \b PNComparisonLikeType which allow to pass messages where
                 value stored in left hand expression contains string specified in right hand expression.
                 The only difference from \b PNComparisonLikeType is what tokens will be added automatically.
     @discussion \b Important: left hand expression can be: \c string, \c array or \c dictionary. For 
                 collections comparison operator work against values (in case of dictionary against of values
                 stored under keys). This operator is \b case-insensitive with evaluated values.
     @note       All instaces of \b PNExpression will produce string which will instruct service to
                 evaluate it to numbers and used uring comparison operation. Expressions may have 
                 constant value or refer to another key-path from message \c metadata payload.
     @discussion \b Example:
     @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"mob.name"];
PNExpression *rightExpression = [PNExpression expressionForConstantValue:@"priest"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonBeginsWithType];
[self.client setFilterPredicate:predicate];
     @endcode
     In example above only messages which will arrive to channel will be those where \c metadata mob's
     name field store value which containst \b priest string in it.
     */
    PNComparisonContainsType
};


#pragma mark - Class forwar

@class PNExpression;


/**
 @brief      Class describes predicate constructor.
 @discussion Predicate constructor allow to avoid typos while defining comparison operations and
             used expressions.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNComparisonPredicate : PNPredicate


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on expression which is placed on the left side from
         comparison operator.
 */
@property (nonatomic, readonly, strong) PNExpression *leftHandExpression;

/**
 @brief  Stores reference on expression which is placed on the right side from
         comparison operator.
 */
@property (nonatomic, readonly, strong) PNExpression *rightHandExpression;

/**
 @brief  Stores one of \c PNComparisonOperatorType emumerator fields to specify 
         what kind of comparison should be performed by preicate.
 */
@property (nonatomic, readonly, assign) PNComparisonOperatorType comparisonOperationType;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Construct comparison predicate with predefined operation type.
 @discussion This approach require more code but eliminates possible type in operations and 
             variables declaration in predicate format string (\b PNPredicate class method).
 @warning    Will throw exception in case if values stored in expressions doesn't meet 
             requirements from comparison operation \c type.
 @discussion \b Example:
 @code
PNExpression *leftExpression = [PNExpression expressionForKeyPath:@"weapon['id']"];
PNExpression *rightExpression = [PNExpression expressionForKeyPath:@"world.weapon['rare']"];
PNComparisonPredicate *perdicate = [PNComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                      rightExpression:rightExpression
                                                                                 type:PNComparisonBeginsWithType];
[self.client setFilterPredicate:predicate];
 @endcode
 
 @param leftExpression  Reference on object which will be on  the left side of operand.
                        \b Important: this property can be only one of these types: \c NSString, 
                        \c NSNumber.
 @param rightExpression Reference on object which will be on the right side of operand.
                        \b Important: this property can be only one of these types: \c NSString, 
                        \c NSNumber, \c NSArray.
 @param type            Compare operand type.
 
 @return Configured and ready to use predicate instance.
 */
+ (instancetype)predicateWithLeftExpression:(id)leftExpression rightExpression:(id)rightExpression
                                       type:(PNComparisonOperatorType)type;

#pragma mark -


@end
