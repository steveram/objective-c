#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 @brief      Class describe comparison expression unit.
 @discussion Comparison predicate requires two expression to run comparison operation on them. This
             class allow to construct instance for comparison. Class also make it possible to run 
             verification on passed data types and for dynamicly evaluated expression.

 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
@interface PNExpression : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief      Construct expression using format string.
 @discussion It is possible to describe complex expression for comparison using this method. Using
             this method it is possible to describe expression which is able to use values from 
             published message \b meta dictionary for calculations.
 @note       By enclosing string or \c %@ into quotes (single or doubled) in format string 
             expression will be instructed to treat this value as constant. If string not enclosed 
             into quotes - it will be trated as key from published message \b meta dictionary.
 @warning    May throw an exception in case if expression contain any comparison or compounding 
             tokens (like &&, || and other).
 @discussion \b Example:
 
 @code
PNExpression *expression = [PNExpression expressionWithFormat:@"numA + numB - %@", @6, nil];
 @endcode
 Expression above allow to use values \c numA and \c numB from \c meta dictionary of published
 messages for evaluation with \b PNComparisonPredicate.
 
 @param expression Stringified expression representation.
 @param ...        Variable arguments list which will should be used for placeholders 
                   substitution in \c expression. \b Warning: all passed elements should be 
                   objects (subclasses of \b NSObject).
 
 @return Configured and ready to use expression instance.
 */
+ (nullable instancetype)expressionWithFormat:(NSString *)expression, ... NS_REQUIRES_NIL_TERMINATION;

/**
 @brief      Construct expression using format string.
 @discussion It is possible to describe complex expression for comparison using this method. Using
             this method it is possible to describe expression which is able to use values from 
             published message \b meta dictionary for calculations.
 @note       By enclosing string or \c %@ into quotes (single or doubled) in format string 
             expression will be instructed to treat this value as constant. If string not enclosed 
             into quotes - it will be trated as key from published message \b meta dictionary.
 @warning    May throw an exception in case if expression contain any comparison or compounding 
             tokens (like &&, || and other).
 @discussion \b Example:
 
 @code
PNExpression *expression = [PNExpression expressionWithFormat:@"%@ + numB - %@" arguments:@[@(32.6f), @6]];
 @endcode
 Expression above allow to use values \c numA and \c numB from \c meta dictionary of published
 messages for evaluation with \b PNComparisonPredicate.
 
 @param expression Stringified expression representation.
 @param arguments  List which will should be used for placeholders substitution in \c expression.
 
 @return Configured and ready to use expression instance.
 */
+ (nullable instancetype)expressionWithFormat:(NSString *)expression arguments:(NSArray *)arguments;

/**
 @brief      Construct expression with predefined value.
 @discussion Expressions used along with \b PNComparisonPredicate to configure left and right hand
             of comparison operation. And this type of expression pass constant value to comparison.
 @note       Only values which is acceptable by JSON object specification can be passed.
 @warning    May throw an exception in case if passed value not copmatible with JSON specification.
 @discussion \b Example:
 
 @code
PNExpression *expression = [PNExpression expressionForConstantValue:@[@"magic",@"words"]];
 @endcode
 @code
PNExpression *expression = [PNExpression expressionForConstantValue:@"this is string"];
 @endcode
 In last code example string constant will be wrapped into double quotes (\c ").
 
 @return Configured and ready to use expression instance.
 */
+ (instancetype)expressionForConstantValue:(id)value;

/**
 @brief      Construct and configure expression to represent key-path in expression.
 @discussion Expressions used along with \b PNComparisonPredicate to configure left and right hand
             of comparison operation. And this type of expression pass constant value to comparison.
 @note       Key-path can be specified as dot-separated access or using square brackets.
 @warning    May throw an exception in case if passed value doesn't represent key-path.
 @discussion \b Example:
 
 @code
PNExpression *expression = [PNExpression expressionForKeyPath:@"region.name"];
 @endcode
 @code
PNExpression *expression = [PNExpression expressionForKeyPath:@"region['name']"];
 @endcode
 Two examples above are equal and provide access to the value stored under \c name field in \c region
 dictionary of message meta.
 
 @return Configured and ready to use expression instance.
 */
+ (instancetype)expressionForKeyPath:(NSString *)string;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
