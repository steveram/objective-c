/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNExpression.h"


#pragma mark Structures

/**
 @brief  Represent structure which is used to describe target expression operation.
 */
struct PNExpressionOperationStructure {
    NSUInteger negate, add, substract, multiply, divide, 
               bitwiseNOT, bitwiseOR, bitwiseAND, bitwiseXOR; 
};

extern const struct PNExpressionOperationStructure PNExpressionOperation;

/**
 @brief  Represent structure which is used to describe type of expression.
 */
struct PNExpressionValueTypeStructure {
    NSUInteger constant;
    NSUInteger keypath, firstIndex, lastIndex;
    NSUInteger operation;
};

extern const struct PNExpressionValueTypeStructure PNExpressionValue;

/**
 @brief  Expression operation type definition.
 */
typedef NSUInteger PNExpressionOperationType;

/**
 @brief  Expression and value type definition.
 */
typedef NSUInteger PNExpressionValueType;


#pragma mark Private interface declaration

@interface PNExpression ()


#pragma mark - Properties

/**
 @brief  Stores reference on expression formar string which should be used during comparison 
         predicate evaluation.
 
 @since 3.8.0
 */
@property (nonatomic, copy) NSString *format;

/**
 @brief  Stores reference on list of arguments which has been passed to by user for format string.
 
 @since 3.8.0
 */
@property (nonatomic, copy) NSArray *arguments;

/**
 @brief  Stores reference on value which has been used during constant expression
         construction.
 */
@property (nonatomic) id value;

/**
 @brief  Stores value data type class so it can be used during serialization.
 */
@property (nonatomic) Class valueType;

/**
 @brief Stores reference on expression value type.
 */
@property (nonatomic, assign) PNExpressionValueType type;

/**
 @brief  Stores reference on type of operation which is described by expression.
 */
@property (nonatomic, assign) PNExpressionOperationType operationType;


#pragma mark - Operation expression

/**
 @brief      Construct and configure expression for specific value data type.
 @discussion Expressions used along with \b PNComparisonPredicate to configure left and right hand
             of comparison operation. And this type of expression pass constant value to comparison.
 @note       Only values which is acceptable by JSON object specification can be passed.
 @warning    May throw an exception in case if passed value not copmatible with JSON specification.
 
 @param type  One of \b PNExpressionValue structure field to describe value type.
 @param value Reference on value which should be represented with expression instance.
 
 @return Configured and ready to use expression instance.
 */
+ (instancetype)expressionWithType:(PNExpressionValueType)type value:(id)value;

/**
 @brief  Construct and configure expression for math operation.
 
 @param type      One of \b PNExpressionOperation structure fields to describe operation type.
 @param arguments List of arguments (from 1 to 2) which take part in math operation.
 
 @return Configured and ready to use expression instance.
 */
+ (instancetype)expressionWithOperation:(PNExpressionOperationType)type arguments:(NSArray *)arguments;

/**
 @brief  Initialize expression for math operation.
 
 @param type      One of \b PNExpressionOperation structure fields to describe operation type.
 @param arguments List of arguments (from 1 to 2) which take part in math operation.
 
 @return Initialized and ready to use expression instance.
 */
- (instancetype)initWithOperation:(PNExpressionOperationType)type arguments:(NSArray *)arguments;

/**
 @brief      Initialize expression with predefined value.
 @discussion Expressions used along with \b PNComparisonPredicate to configure left and right hand
             of comparison operation. And this type of expression pass constant value to comparison.
 @note       Only values which is acceptable by JSON object specification can be passed.
 @warning    May throw an exception in case if passed value not copmatible with JSON specification.
 
 @return Initialized and ready to use expression instance.
 */
- (instancetype)initWithConstantValue:(id)value;

/**
 @brief      Initialize expression with type and predefined value.
 @discussion Expressions used along with \b PNComparisonPredicate to configure left and right hand
             of comparison operation. And this type of expression pass constant value to comparison.
 @note       Only values which is acceptable by JSON object specification can be passed.
 @warning    May throw an exception in case if passed value not copmatible with JSON specification.
 
 @param type  One of \b PNExpressionValue structure field to describe value type.
 @param value Reference on value which should be represented with expression instance.
 
 @return Initialized and ready to use expression instance.
 */
- (instancetype)initExpression:(PNExpressionValueType)type withValue:(id)value;


#pragma mark - Serialization

/**
 @brief  Represent expression object with string.
 
 @return Stringified expression.
 */
- (NSString *)stringValue;

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

/**
 @brief  Represent expression constant value as string.
 
 @return Stringified expression's constant value.
 */
- (NSString *)stringifiedConstant;

/**
 @brief  Try to retrieve normalized \c value. In case if \b PNEpression is passed
         it's value will be returne instea of expression instance itself.
 
 @return Un-wrapped value.
 */
- (id)unwrapValueIfRequired:(id)value;

/**
 @brief  Represent passed array as string.
 
 @return Stringified array.
 */
- (NSString *)stringifiedArrayValue:(NSArray *)value;

/**
 @brief  Represent passed dictionary as string.
 
 @return Stringified dictionary.
 */
- (NSString *)stringifiedDictionaryValue:(NSDictionary *)value;

/**
 @brief  Represent expression's value as key-path string.
 
 @return Stringified expression's constant value.
 */
- (NSString *)keyPath;


#pragma mark - Misc

/**
 @brief  Some expression instance types require additional value processing.
 */
- (void)normalizeValueIfRequired;

/**
 @brief  Put \c string in quotes if required.
 
 @param string Reference on string which should be analyzed and enclosed into
               quotes if required.
 
 @return Reference on new quoted string.
 */
- (NSString *)quotedString:(NSString *)string;

/**
 @brief  Translate operation type to human-readable value.
 
 @param type One of \b PNExpressionOperation structure fields to describe operation type.
 
 @return Stringified operation type.
 */
+ (NSString *)stringifiedOperation:(PNExpressionOperationType)type;

/**
 @brief  Retrieve expected expression operation format.
 
 @param type One of \b PNExpressionOperation structure fields for which format required.
 
 @return Suitable format string for passed operatino \c type.
 */
+ (NSString *)expressionFormatForOperation:(PNExpressionOperationType)type;

/**
 @brief  Throw an exception in case if passed value can't be serialized to JSON.
 
 @param value Reference on value which should be verified.
 */
+ (void)throwIfConstantValueUnsupported:(id)value;

/**
 @brief  Check whether passed value is supported (can be serialized to JSON) or
         not.
 
 @param value Reference on value whcih should be verified.
 
 @return \c YES in case if value supported,
 */
+ (BOOL)isConstantValueSupported:(id)value;

#pragma mark -


@end
