/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import <Foundation/Foundation.h>


#pragma mark Static

/**
 @brief  Stores constant which specify how many known token types is stored in C-array. 
 */
static NSUInteger const kPNScannerTokenTableSize = 32;


#pragma mark - Types and Structures

/**
 @brief  Represent structure which is used during tokenization process.
 */
struct PNPredicateTokenStructure {
    NSUInteger end, unknown;
    NSUInteger leftParenthesis, rightParenthesis, leftBracket, rightBracket, 
               leftBrace, rightBrace;
    NSUInteger exclamation, equals, notEquals, lessThan, lessThanOrEqual, greaterThan, 
               greaterThanOrEqual;
    NSUInteger dot, comma, tilde, bar, ampersand, caret, plus, minus,
               slash, asterisk, number; 
    NSUInteger string, stringDouble, stringSingle;
    NSUInteger identifier, AND, OR, NOT, between, beginsWith, contains,
               endsWith, IN, like;
}; 

extern const struct PNPredicateTokenStructure PNPredicateToken;

/**
 @brief  Represent structure which is used to describe current scanner's state.
 */
struct PNPredicateScanningStructure {
    NSUInteger skip, scanning;
    NSUInteger identifier, zero, integer, real;
    NSUInteger stringDouble, stringDoubleEscaped, stringDoubleEscapeBuffered, 
               stringSingle, stringSingleEscaped, stringSingleEscapeBuffered;
    NSUInteger leftParenthesis, rightParenthesis, leftBracket, rightBracket, 
               leftBrace, rightBrace;
    NSUInteger exclamation, equals, lessThan, greaterThan;
    NSUInteger bar, ampersand; 
}; 

extern const struct PNPredicateScanningStructure PNPredicateScanning;

/**
 @brief  Represent structure which is used by scanner during numeric
         values scanning.
 */
struct PNPRedicateNumericValue {
    NSUInteger integerValue;
    double realValue;
    double realValueFraction;
};

/**
 @brief  Token type definition.
 */
typedef NSUInteger PNPredicateTokenType;

/**
 @brief  Scanner's state definition.
 */
typedef NSUInteger PNPredicateScannerState;

/**
 @brief  Represent structure which is used to describe single token data.
 */
struct PNPredicateTokenData {
    unichar token;
    PNPredicateTokenType type;
    PNPredicateScannerState state;
};

/**
 @brief  Definition of the structure which store token's information inside of C-array.
 */
typedef struct PNPredicateTokenData PNPredicateScannerTokens;
