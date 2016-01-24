/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNPredicate.h"
#import "PNPredicate+ScannerStructures.h"

NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface PNPredicate () {
    
    unichar *_unicharPredicateFormat;
    PNPredicateScannerTokens _tokenTable[kPNScannerTokenTableSize];
}

/**
 @brief  Stores reference on pre-processed filter predicate.
 */
@property (nonatomic, copy) NSString *predicateExpression;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

+ (instancetype)predicateFromStringExpression:(NSString *)expression;

/**
 @brief      Initialize filter predicate instance using user-defined format.
 @discussion Predicate use provided format to evaluate it against published message \b meta 
             dictionary to identify whether message should be delivered to the client or not.
 @warning    Format should be defined in a way which will produce \b bool evalutation result. If 
             wrong format has been passed exception will be thrown.
 
 @param expression    Format which describes comparison operation between few expressions.
 
 @return Initialized and ready to use instance (if no exception will be thrown).
 */
- (instancetype)initFromStringExpression:(NSString *)expression;


///------------------------------------------------
/// @name Translation
///------------------------------------------------

/**
 @brief  Translate user-specified comparision details to string.
 
 @return Stringified comparision / logical operation.
 */
- (NSString *)stringValue;

/**
 @brief  Translate user-specified comparision details to string w/o enclosing result
         into parenthesis.
 
 @return Stringified comparision / logical operation.
 */
- (NSString *)stringValueWithOutParenthesis;


#pragma mark - Misc

/**
 @brief  Substitute all \c %@ tokens with actual \c values.
 
 @param string Reference on string which contains tokens which should be substituted.
 @param values Reference on values which should be used during substitution process.
 
 @return String with substituted tokens.
 */
+ (NSString *)substitutedString:(NSString *)string withValues:(NSArray *)values;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
