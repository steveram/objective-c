/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNPredicate+Protected.h"
#import "PNPredicate+ScannerStructures.h"
#import "PNExpression+Protected.h"
#import "PNComparisonPredicate.h"
#import "PNOperationPredicate.h"
#import "PNCompoundPredicate.h"
#import "PNPredicate+Scanner.h"
#import <objc/runtime.h>


#pragma mark Extern

/**
 @brief  Predicate tokens structure initialuization.
 */
const struct PNPredicateTokenStructure PNPredicateToken = {
    .end = 0, .unknown = 1,
    .leftParenthesis = 2, .rightParenthesis = 3, .leftBracket = 4, .rightBracket = 5, 
    .leftBrace = 6, .rightBrace = 7,
    .exclamation = 8, .equals = 9, .notEquals = 10, .lessThan = 11, .lessThanOrEqual = 12, .greaterThan = 13,
    .greaterThanOrEqual = 14, 
    .dot = 15, .comma = 16, .tilde = 17, .bar = 18, .ampersand = 19, .caret = 20, .plus = 21, .minus = 22, 
    .slash = 23, .asterisk = 24, .number = 25,
    .string = 26, .stringDouble = 27, .stringSingle = 28, 
    .identifier = 29, .AND = 30, .OR = 31, .NOT = 32, .between = 33, .beginsWith = 34,
    .contains = 35, .endsWith = 36, .IN = 37, .like = 38
};

const struct PNPredicateScanningStructure PNPredicateScanning = {
    .skip = 0, .scanning = 1,
    .identifier = 2, .zero = 3, .integer = 4, .real = 5,
    .stringDouble = 6, .stringDoubleEscaped = 7, .stringDoubleEscapeBuffered = 8, 
    .stringSingle = 9, .stringSingleEscaped = 10, .stringSingleEscapeBuffered = 11, 
    .leftParenthesis = 12, .rightParenthesis = 13, .leftBracket = 14, .rightBracket = 15, 
    .leftBrace = 15, .rightBrace = 16,
    .exclamation = 17, .equals = 18, .lessThan = 19, .greaterThan = 20,
    .bar = 21, .ampersand = 22
};


#pragma mark - Private interface declaration

@interface PNPredicate (ScannerPrivate) 


#pragma mark - Information

/**
 @brief  Retrieve information about current predicate string length.
 
 @return String length.
 */
- (NSUInteger)predicateLength;

/**
 @brief  Update predicate string length information.
 
 @param predicateLength New length which should be catched.
 */
- (void)setPredicateLength:(NSUInteger)predicateLength;

/**
 @brief  Retrieve reference on current scanner's position in 
         predicate expression.
 
 @return Scanner head position.
 */
- (NSUInteger)position;

/**
 @brief  Update scanner's head position by moving it to specified position.
 
 @param position Position to which scanner's head should be moved in
                 predicate expression.
 */
- (void)setPosition:(NSUInteger)position;

/**
 @brief  Retrieve reference on recently detected token position.
 
 @return Token start position.
 */
- (NSUInteger)tokenPosition;

/**
 @brief  Update token's start position.
 
 @param tokenPosition New token position which should be stored.
 */
- (void)setTokenPosition:(NSUInteger)tokenPosition;


#pragma mark - Processing

/**
 @brief  Search for expression string which can be translated to \b PNPredicate.
 
 @return \b PNPredicate instance in case if expression string has been found.
 */
- (instancetype)nextPredicate;

/**
 @brief  Try to receive reference on next compound predicate (with \b OR composition
         type).
 
 @return \b PNCompoundPredicate instance in case if expression string has been found.
 */
- (instancetype)nextNextPredicatesCompoundWithOR;

/**
 @brief  Try to receive reference on next compound predicate (with \b AND composition
         type).
 
 @return \b PNCompoundPredicate instance in case if expression string has been found.
 */
- (instancetype)nextNextPredicatesCompoundWithAND;

/**
 @brief  Try to receive reference on next compound predicate (with \b NOT composition
         type).
 
 @return \b PNCompoundPredicate instance in case if expression string has been found.
 */
- (instancetype)nextNextPredicatesCompoundWithNOT;

/**
 @brief  Try to revceive reference on non-compound predicate.
 
 @return \b PNPredicate instance in case if expression string has been found.
 */
- (instancetype)nextPrimaryPredicate;

/**
 @brief  Try to receive on expression comparison predicate.
 
 @return \b PNComparisonPredicate instance in case if expression string has been found.
 */
- (instancetype)nextComparisonPredicate;

/**
 @brief  Try to read string expression which starts from current scanner's
         position.
 
 @return \b PNExpression instance if stringified expression has been found.
 */
- (PNExpression *)nextExpression;

/**
 @brief  Try to read string expression which starts from current scanner's
         position to compose expression with binary operations.
 
 @return \b PNExpression instance if stringified expression has been found. 
 */
- (PNExpression *)nextAdditiveExpression;
- (PNExpression *)nextMultiplicationExpression;

/**
 @brief  Try to read string expression which starts from current scanner's
         position to compose expression with bitwise operations.
 
 @return \b PNExpression instance if stringified expression has been found. 
 */
- (PNExpression *)nextBitwiseNOTExpression;
- (PNExpression *)nextBitwiseORExpression;
- (PNExpression *)nextBitwiseANDExpression;
- (PNExpression *)nextBitwiseXORExpression;

/**
 @brief  Try to read string expression which starts from current scanner's
         position to compose expression with arguments unary operations.
 
 @return \b PNExpression instance if stringified expression has been found. 
 */
- (PNExpression *)nextUnaryExpression;

/**
 @brief  Try to read string expression which starts from current scanner's
         position to compose expression with data key-path.
 
 @return \b PNExpression instance if stringified expression has been found. 
 */
- (PNExpression *)nextKeyPathExpression;

/**
 @brief  Try to read string expression which starts from current scanner's
         position to compose expression with non-composition and calculation data.
 
 @return \b PNExpression instance if stringified expression has been found. 
 */
- (PNExpression *)nextPrimaryExpression;


#pragma mark - Tokenization

/**
 @brief  Try to retrieve type of the next token from current scanner's position.
 
 @return One of \c PNPredicateToken structure fields to reprecent type of the token.
 */
- (PNPredicateTokenType)nextTokenType;

/**
 @brief      Try to read next token from format string into variable passed 
             by reference.
 @discussion Using tokenization logic try to define type of the token and 
             store it into provided storage.
 
 @param token Reference on storage where token value should be stored.
 
 @return One of \c PNPredicateToken structure fields to reprecent type of the token.
 */
- (PNPredicateTokenType)getNextToken:(id *)token;

/**
 @brief  Step scanner's position to skip next token.
 */
- (void)skipNextToken;

/**
 @brief  Handle scanner's initial state and define current token type and expected
         scanner's state.
 
 @param state Pointer to the variable which store current scanner's state information.
              This value will be updated basing on internal logic.
 @param code  Code of the char at which scanner's head is pointing now.
 @param type  Pointer to the variable which store information about current token type.
 
 @return \c YES in case if scanning should be continued. In case of \c NO scanner will stop
         and return token type back.
 */
- (BOOL)handleScanningState:(out PNPredicateScannerState *)state usingCharCode:(unichar)code 
                  tokenType:(out PNPredicateTokenType *)type;

/**
 @brief  Handle identifier scanning start event.
 */
- (void)handleIdentifierScanningStart;

/**
 @brief  Handle scanner's position movement along identifier inside of predicate
         expression.
 
 @param code  Code of the char at which scanner's head is pointing now.
 @param token Reference on storage where token value should be stored.
 @param type  Pointer to the variable which store information about current token type.
 
 @return \c YES in case if scanning should be continued. In case of \c NO scanner will stop
         and return token type back.
 */
- (BOOL)handleIdentifierCharCode:(unichar)code identifier:(inout id *)token 
                            type:(out PNPredicateTokenType *)type;

/**
 @brief  Handle scanner's position movement along numeric value inside of predicate
         expression.
 
 @param number Reference on initialized structure which will store number scanning
               progress information.
 @param code   Code of the char at which scanner's head is pointing now.
 @param state  Pointer to the variable which store current scanner's state information.
               This value will be updated basing on internal logic.
 @param token  Reference on storage where token value should be stored.
 
 @return \c YES in case if scanning should be continued. In case of \c NO scanner will stop
         and return token type back.
 */
- (BOOL)handleNumberScanning:(struct PNPRedicateNumericValue *)number withCharCode:(unichar)code 
                       state:(inout PNPredicateScannerState *)state number:(id *)token;

/**
 @brief  Handle scanner's position movement along quoted string value inside of predicate
         expression.
 
 @param code   Code of the char at which scanner's head is pointing now.
 @param state  Pointer to the variable which store current scanner's state information.
               This value will be updated basing on internal logic.
 @param token  Reference on storage where token value should be stored.
 
 @return \c YES in case if scanning should be continued. In case of \c NO scanner will stop
         and return token type back.
 */
- (BOOL)handleStringQuoteCharCode:(unichar)code withState:(inout PNPredicateScannerState *)state 
                           string:(id *)token;

/**
 @brief  Handle scanner's position movement along string value inside of predicate
         expression.
 
 @param code   Code of the char at which scanner's head is pointing now.
 @param state  Pointer to the variable which store current scanner's state information.
               This value will be updated basing on internal logic.
 @param token  Reference on storage where token value should be stored.
 
 @return \c YES in case if scanning should be continued. In case of \c NO scanner will stop
         and return token type back.
 */
- (BOOL)handleStringCharCode:(unichar)code withState:(inout PNPredicateScannerState *)state 
                      string:(id *)token;

/**
 @brief  Handle scanner's position movement along comparison inside of predicate
         expression.
 
 @param code   Code of the char at which scanner's head is pointing now.
 @param state  Pointer to the variable which store current scanner's state information.
               This value will be updated basing on internal logic.
 @param type  Pointer to the variable which store information about current token type.
 
 @return \c YES in case if scanning should be continued. In case of \c NO scanner will stop
         and return token type back.
 */
- (BOOL)handleComparisonCharCode:(unichar)code withState:(inout PNPredicateScannerState *)state 
                            type:(PNPredicateTokenType *)type;


#pragma mark - Misc

/**
 @brief  Prepare all information which is used by scanner category.
 */
- (void)prepareScanner;

/**
 @brief  Fill up C-array with information about tokens and
         target scanner state.
 */
- (void)prepareTokensTable;

/**
 @brief  Bind single token to it's type and target scanner state.
 
 @param character Reference on character from token.
 @param index     Index at which token should be added to array.
 @param type      One of \b PNPredicateTokenType structure fields to identify token type.
 @param state     One of \b PNPredicateScannerState structure fields to specify target scanner state.
 */
- (void)bind:(unichar)character atIndex:(NSUInteger)index toToken:(PNPredicateTokenType)type 
       state:(PNPredicateScannerState)state;

/**
 @brief  Extract token data by char code.
 
 @param character Code of the character for which token data should be retreieved.
 
 @return Initialized \b PNPredicateTokenData struct.
 */
- (struct PNPredicateTokenData)tokenDataForChar:(unichar)character;

/**
 @brief  Check hether passed char code is related to one of control chars or not.
 
 @param code Char code against which check should be done.
 
 @return \c YES in case if passed \c code belongs to controlling chars set.
 */
- (BOOL)isControlCharCode:(unichar)code;

/**
 @brief  Check hether passed char code is related to one of identifier-allowed
         chars or not.
 
 @param code Char code against which check should be done.
 
 @return \c YES in case if passed \c code belongs to chars set allowed for identifier.
 */
- (BOOL)isIdentifierCharCode:(unichar)code;

/**
 @brief  Try to extract token type from retrieved token value.
 
 @param identifier Reference on recently received identifier which should be analyzed.
 
 @return One of \b PNPredicateToken structure fields which will help to identify token
         type.
 */
- (PNPredicateTokenType)tokenTypeForIdentifier:(NSString *)identifier;

/**
 @brief  Translate passe token type to comparison operation type.
 
 @param token One of \b PNPredicateToken structure fields which allow to identify token
              type.
 
 @return One of \b PNComparisonOperatorType enum fields to ientify comparison operation 
         type.
 */
- (PNComparisonOperatorType)comparisonOperationForToken:(PNPredicateTokenType)token;

/**
 @brief  Check whether passed token can be used with comparison predicate or not.
 
 @param token One of \b PNPredicateToken structure fields which allow to identify token
              type.
 
 @return \c YES in case if token can be use with comparison predicate.
 */
- (BOOL)isComparisonToken:(PNPredicateTokenType)token;

/**
 @brief  Retrieve reference on token's characters basing on current scanner position and
         last known token location.
 
 @return Pointer to token characters array.
 */
- (const unichar *)tokenCharacters;

/**
 @brief  Calculate token's length basing on current scanner's position and last known 
         token location.
 
 @return Total token lenght.
 */
- (NSUInteger)tokenLength;

/**
 @brief  Try to translate passed token type to stringified value.
 
 @param type One of \b PNPredicateToken structure fields which should be translated
             to string.
 
 @return Stringified token type.
 */
- (NSString *)stringifiedTokenType:(PNPredicateTokenType)type;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPredicate (Scanner)


#pragma mark - Information

- (NSUInteger)predicateLength {
    
    return [objc_getAssociatedObject(self, "predicateLength") unsignedLongValue];
}

- (void)setPredicateLength:(NSUInteger)predicateLength {
    
    objc_setAssociatedObject(self, "predicateLength", @(predicateLength), OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)position {
    
    return [objc_getAssociatedObject(self, "position") unsignedLongValue];
}

- (void)setPosition:(NSUInteger)position {

    objc_setAssociatedObject(self, "position", @(position), OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)tokenPosition {
    
    return [objc_getAssociatedObject(self, "tokenPosition") unsignedLongValue];
}

- (void)setTokenPosition:(NSUInteger)tokenPosition {
    
    objc_setAssociatedObject(self, "tokenPosition", @(tokenPosition), OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Translation

- (instancetype)predicate {
    
    [self prepareScanner];
    [self prepareTokensTable];
    __typeof(self) predicate = [self nextPredicate];
    PNPredicateTokenType nextTokenType = [self nextTokenType];
    if (nextTokenType != PNPredicateToken.end) {
        
        [self throwExecptionWithFormat:@"There is extraneous tokens at the"
         " end of the predicate string.", nil];
    }
    
    return predicate;
}


#pragma mark - Processing

- (instancetype)nextPredicate {
    
    return [self nextNextPredicatesCompoundWithOR];
}

- (instancetype)nextNextPredicatesCompoundWithOR {
    
    __block PNPredicate *leftHandPredicate = [self nextNextPredicatesCompoundWithAND];
    [self nextTokensWithTypes:@[@(PNPredicateToken.OR)] withBlock:^(__unused PNPredicateTokenType type) {
        
        PNPredicate *rightHandPredicate = [self nextNextPredicatesCompoundWithAND];
        if (leftHandPredicate && rightHandPredicate) {
            
            NSArray *predicates = @[leftHandPredicate, rightHandPredicate];
            leftHandPredicate = [PNCompoundPredicate orPredicateWithSubpredicates:predicates];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandPredicate;
}

- (instancetype)nextNextPredicatesCompoundWithAND {
    
    __block PNPredicate *leftHandPredicate = [self nextNextPredicatesCompoundWithNOT];
    [self nextTokensWithTypes:@[@(PNPredicateToken.AND)] withBlock:^(__unused PNPredicateTokenType type) {
        
        PNPredicate *rightHandPredicate = [self nextNextPredicatesCompoundWithNOT];
        if (leftHandPredicate && rightHandPredicate) {
            
            NSArray *predicates = @[leftHandPredicate, rightHandPredicate];
            leftHandPredicate = [PNCompoundPredicate andPredicateWithSubpredicates:predicates];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandPredicate;
}

- (instancetype)nextNextPredicatesCompoundWithNOT {
    
    PNPredicate *predicate;
    if ([self nextTokenType] == PNPredicateToken.NOT) {
        
        [self skipNextToken];
        PNPredicate *nextPredicate = [self nextNextPredicatesCompoundWithNOT];
        if ([nextPredicate isKindOfClass:PNCompoundPredicate.class]) {
            
            PNCompoundPredicate *compondPredicate = (PNCompoundPredicate *)nextPredicate;
            if (compondPredicate.compoundPredicateType == NSNotPredicateType) {
                
                predicate = [compondPredicate.subpredicates firstObject];
            }
        }
        if (!predicate) { predicate = [PNCompoundPredicate notPredicateWithSubpredicate:nextPredicate]; }
    }
    else { predicate = [self nextPrimaryPredicate]; }
    
    return predicate;
}


- (instancetype)nextPrimaryPredicate {
    
    PNPredicate *primaryPredicate = nil;
    if ([self nextTokenType] == PNPredicateToken.leftParenthesis) {
        
        [self skipNextToken];
        primaryPredicate = [self nextPredicate];
        [self throwExceptionIfNotExprectedToken:PNPredicateToken.rightParenthesis];
        
        if ([primaryPredicate isKindOfClass:PNOperationPredicate.class]) {
            
            PNPredicateTokenType nextTokenType = [self nextTokenType];
            if ([self isComparisonToken:nextTokenType]) {
                
                [self skipNextToken];
                PNPredicate *rightHandPredicate = [self nextPredicate];
                if ([rightHandPredicate isKindOfClass:PNOperationPredicate.class]) {
                    
                    PNComparisonOperatorType comparisonOperation = [self comparisonOperationForToken:nextTokenType];
                    PNExpression *leftHandExpression = ((PNOperationPredicate *)primaryPredicate).expression;
                    PNExpression *rightHandExpression = ((PNOperationPredicate *)rightHandPredicate).expression;
                    primaryPredicate = [PNComparisonPredicate predicateWithLeftExpression:leftHandExpression
                                                                          rightExpression:rightHandExpression 
                                                                                     type:comparisonOperation];
                }
                else { [self throwExecptionWithFormat:@"Operation group expected."]; }
            }
            else if ([self isOperationToken:nextTokenType]){
                
                [self skipNextToken];
                PNPredicate *rightHandPredicate = [self nextPredicate];
                if (primaryPredicate && rightHandPredicate) {
                    
                    PNExpressionOperationType operationType = [self operationForToken:nextTokenType];
                    PNExpression *leftHandExpression = ((PNOperationPredicate *)primaryPredicate).expression;
                    PNExpression *rightHandExpression = ((PNOperationPredicate *)rightHandPredicate).expression;
                    NSArray *predicates = @[leftHandExpression, rightHandExpression];
                    PNExpression *expression = [PNExpression expressionWithOperation:operationType
                                                                           arguments:predicates];
                    primaryPredicate = [PNOperationPredicate operationPredicateWithExpression:expression];
                }
                else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
            }
        }
    }
    else { primaryPredicate = [self nextComparisonPredicate]; }
    
    return primaryPredicate;
}

- (instancetype)nextComparisonPredicate {
    
    PNPredicate *comparisonPredicate = nil;
    PNExpression *leftHandExpression = [self nextExpression];
    PNPredicateTokenType nextTokenType = [self nextTokenType];
    if (nextTokenType == PNPredicateToken.between) {
        
        [self skipNextToken];
        PNExpression *rightHandExpression = [self nextExpression];
        if (!rightHandExpression) { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
        PNExpression *firstElementExpression = [PNExpression expressionWithType:PNExpressionValue.firstIndex 
                                                                          value:@[rightHandExpression]];
        PNExpression *lastElementExpression = [PNExpression expressionWithType:PNExpressionValue.lastIndex 
                                                                         value:@[rightHandExpression]];
        PNComparisonPredicate *greaterThanOrEqual = [PNComparisonPredicate predicateWithLeftExpression:leftHandExpression 
                                                     rightExpression:firstElementExpression type:PNComparisonGreaterThanOrEqualToType];
        PNComparisonPredicate *lessThanOrEqual = [PNComparisonPredicate predicateWithLeftExpression:leftHandExpression 
                                                 rightExpression:lastElementExpression type:PNComparisonLessThanOrEqualType];
        
        comparisonPredicate = [PNCompoundPredicate andPredicateWithSubpredicates:@[greaterThanOrEqual, lessThanOrEqual]];
    }
    else if ([self isComparisonToken:nextTokenType]) {
        
        [self skipNextToken];
        PNExpression *rightHandExpression = [self nextExpression];
        if (!leftHandExpression) { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
        comparisonPredicate = [PNComparisonPredicate predicateWithLeftExpression:leftHandExpression 
                               rightExpression:rightHandExpression type:[self comparisonOperationForToken:nextTokenType]];
    }
    else {
        
        comparisonPredicate = [PNOperationPredicate operationPredicateWithExpression:leftHandExpression];
    }

    return comparisonPredicate;
}

- (PNExpression *)nextExpression {
    
    return [self nextBitwiseORExpression];
}

- (void)nextTokensWithTypes:(NSArray *)tokenTypes withBlock:(void(^)(PNPredicateTokenType type))block {
    
    [self nextTokens:YES withTypes:tokenTypes withBlock:block];
}

- (void)nextTokens:(BOOL)skipToken withTypes:(NSArray *)tokenTypes withBlock:(void(^)(PNPredicateTokenType type))block {
    
    do {
        
        NSNumber *type = @([self nextTokenType]);
        if ([tokenTypes containsObject:type]) { 
            
            if (skipToken) { [self skipNextToken]; }
            block(type.unsignedIntegerValue); 
        }
        else { break; }
    } while (YES);
}

- (PNExpression *)nextBitwiseORExpression {
    
    __block PNExpression *leftHandExpression = [self nextBitwiseXORExpression];
    [self nextTokensWithTypes:@[@(PNPredicateToken.bar)] withBlock:^(PNPredicateTokenType type) {
        
        PNExpression *rightHandExpression = [self nextBitwiseXORExpression];
        if (leftHandExpression && rightHandExpression) {
            
            NSArray *expressions = @[leftHandExpression, rightHandExpression];
            [self throwExceptionForToken:type ifExpectedObjectIsNil:rightHandExpression];
            leftHandExpression = [PNExpression expressionWithOperation:PNExpressionOperation.bitwiseOR
                                                             arguments:expressions];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandExpression;
}

- (PNExpression *)nextBitwiseXORExpression {
    
    __block PNExpression *leftHandExpression = [self nextBitwiseANDExpression];
    [self nextTokensWithTypes:@[@(PNPredicateToken.caret)] withBlock:^(PNPredicateTokenType type) {
        
        PNExpression *rightHandExpression = [self nextBitwiseANDExpression];
        if (leftHandExpression && rightHandExpression) {
            
            NSArray *predicates = @[leftHandExpression, rightHandExpression];
            [self throwExceptionForToken:type ifExpectedObjectIsNil:rightHandExpression];
            leftHandExpression = [PNExpression expressionWithOperation:PNExpressionOperation.bitwiseXOR
                                                             arguments:predicates];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandExpression;
}

- (PNExpression *)nextBitwiseANDExpression {
    
    __block PNExpression *leftHandExpression = [self nextAdditiveExpression];
    [self nextTokensWithTypes:@[@(PNPredicateToken.ampersand)] withBlock:^(PNPredicateTokenType type) {
        
        PNExpression *rightHandExpression = [self nextAdditiveExpression];
        if (leftHandExpression && rightHandExpression) {
            
            NSArray *expressions = @[leftHandExpression, rightHandExpression];
            [self throwExceptionForToken:type ifExpectedObjectIsNil:rightHandExpression];
            leftHandExpression = [PNExpression expressionWithOperation:PNExpressionOperation.bitwiseAND
                                                             arguments:expressions];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandExpression;
}

- (PNExpression *)nextAdditiveExpression {
    
    __block PNExpression *leftHandExpression = [self nextMultiplicationExpression];
    [self nextTokensWithTypes:@[@(PNPredicateToken.plus), @(PNPredicateToken.minus)] 
                    withBlock:^(PNPredicateTokenType type) {
        
        PNExpression *rightHandExpression = [self nextMultiplicationExpression];
        [self throwExceptionForToken:type ifExpectedObjectIsNil:rightHandExpression];
        PNExpressionOperationType operationType = PNExpressionOperation.add;
        if (type == PNPredicateToken.minus) { operationType = PNExpressionOperation.substract; }
        if (leftHandExpression && rightHandExpression) {
            
            NSArray *expressions = @[leftHandExpression, rightHandExpression];
            leftHandExpression = [PNExpression expressionWithOperation:operationType 
                                                             arguments:expressions];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandExpression;
}

- (PNExpression *)nextMultiplicationExpression {
    
    __block PNExpression *leftHandExpression = [self nextBitwiseNOTExpression];
    [self nextTokensWithTypes:@[@(PNPredicateToken.asterisk), @(PNPredicateToken.slash)] 
                    withBlock:^(PNPredicateTokenType type) {
        
        PNExpression *rightHandExpression = [self nextBitwiseNOTExpression];
        [self throwExceptionForToken:type ifExpectedObjectIsNil:rightHandExpression];
        PNExpressionOperationType operationType = PNExpressionOperation.multiply;
        if (type == PNPredicateToken.slash) { operationType = PNExpressionOperation.divide; }
        if (leftHandExpression && rightHandExpression) {
            
            NSArray *expressions = @[leftHandExpression, rightHandExpression];
            leftHandExpression = [PNExpression expressionWithOperation:operationType
                                                             arguments:expressions];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandExpression;
}

- (PNExpression *)nextBitwiseNOTExpression {
    
    PNExpression *expression = nil;
    if ([self nextTokenType] == PNPredicateToken.tilde) {
        
        [self skipNextToken];
        PNExpression *nextExpression = [self nextBitwiseNOTExpression];
        [self throwExceptionForToken:PNPredicateToken.tilde ifExpectedObjectIsNil:nextExpression];
        if (nextExpression.operationType == PNExpressionOperation.bitwiseNOT) {
            
            expression = [nextExpression.arguments firstObject];
        }
        if (!expression) { 
            
            expression = [PNExpression expressionWithOperation:PNExpressionOperation.bitwiseNOT
                                                     arguments:@[nextExpression]]; 
        }
    }
    else { expression = [self nextUnaryExpression]; }
    
    return expression;
}

- (PNExpression *)nextUnaryExpression {
    
    PNExpression *expression = nil;
    if ([self nextTokenType] == PNPredicateToken.minus) {
        
        [self skipNextToken];
        PNExpression *nextExpression = [self nextUnaryExpression];
        [self throwExceptionForToken:PNPredicateToken.minus ifExpectedObjectIsNil:expression];
        if (nextExpression.operationType == PNExpressionOperation.negate) {
            
            expression = [nextExpression.arguments firstObject];
        }
        if (!expression) { 
            
            expression = [PNExpression expressionWithOperation:PNExpressionOperation.negate
                                                     arguments:@[nextExpression]]; 
        }
    }
    else { expression = [self nextKeyPathExpression]; }
    
    return expression;
}

- (PNExpression *)nextKeyPathExpression {
    
    __block PNExpression *leftHandExpression = [self nextPrimaryExpression];
    [self nextTokensWithTypes:@[@(PNPredicateToken.dot), @(PNPredicateToken.leftBracket)] 
                    withBlock:^(PNPredicateTokenType type) {
        
        PNExpression *rightHandExpression = nil;
        if (type == PNPredicateToken.dot) { rightHandExpression = [self nextPrimaryExpression]; }
        else {
            
            rightHandExpression = [self nextExpression];
            [self throwExceptionIfNotExprectedToken:PNPredicateToken.rightBracket];
        }
        [self throwExceptionForToken:type ifExpectedObjectIsNil:rightHandExpression];
        if (leftHandExpression && rightHandExpression) {
            
            NSArray *expressions = @[leftHandExpression, rightHandExpression];
            leftHandExpression = [PNExpression expressionWithType:PNExpressionValue.keypath
                                                            value:expressions];
        }
        else { [self throwExecptionWithFormat:@"Unexpected token in predicate format."]; }
    }];
    
    return leftHandExpression;
}

- (PNExpression *)nextPrimaryExpression {
    
    id token = nil;
    PNExpression *expression = nil;
    PNPredicateTokenType type = [self nextTokenType];
    if (type == PNPredicateToken.end) {
        
        [self throwExecptionWithFormat:@"Encountered EOF while parsing expression", nil];
    }
    else if (type == PNPredicateToken.leftParenthesis) {
        
        [self skipNextToken];
        expression = [self nextExpression];
        [self throwExceptionIfNotExprectedToken:PNPredicateToken.rightParenthesis];
    }
    else if (type == PNPredicateToken.leftBracket || type == PNPredicateToken.leftBrace) {
        
        [self skipNextToken];
        PNPredicateTokenType expect = (type == PNPredicateToken.leftBracket ? 
                                       PNPredicateToken.rightBracket : PNPredicateToken.rightBrace);
        NSMutableArray *array = [NSMutableArray new];
        while ([self nextTokenType] != expect) {
            
            if (array.count && [self nextTokenType] == PNPredicateToken.comma) { [self skipNextToken]; }
            PNExpression *expressionw = [self nextExpression];
            [array addObject:expressionw];
        }
        [self throwExceptionIfNotExprectedToken:expect];
        expression = [PNExpression expressionForConstantValue:array];
    }
    else if (type == PNPredicateToken.identifier) {
        
        [self getNextToken:&token];
        expression = [PNExpression expressionForKeyPath:token];
    }
    else if (type == PNPredicateToken.string || type == PNPredicateToken.number) {
        
        [self getNextToken:&token];
        expression = [PNExpression expressionForConstantValue:token];
    }
    
    return expression;
}

- (void)throwExceptionIfNotExprectedToken:(PNPredicateTokenType)token {
    
    PNPredicateTokenType scannedToken = [self getNextToken:NULL];
    if (scannedToken != token) {
        
        [self throwExecptionWithFormat:@"Expected \"%@\" token, got \"%@\"", 
         [self stringifiedTokenType:token], ([self stringifiedTokenType:scannedToken]?: @"unknown"), nil];
    }
}

- (void)throwExceptionForToken:(PNPredicateTokenType)type ifExpectedObjectIsNil:(id)object {
    
    if (!object) {
        
        [self throwExecptionWithFormat:@"Expecting expression after %@", 
         [self stringifiedTokenType:type], nil];
    }
}

- (void)throwExecptionWithFormat:(NSString *)reason, ... {
    
    va_list arguments;
    va_start(arguments, reason);
    NSString *exceptionReason = [[NSString alloc] initWithFormat:reason arguments:arguments];
    va_end(arguments);
    
    [NSException raise:NSInvalidArgumentException format:@"Format string parsing failed: \"%@\" because of: %@",
     self.predicateExpression, exceptionReason];
}


#pragma mark - Tokenization

- (PNPredicateTokenType)nextTokenType {

    NSUInteger position = self.position;
    PNPredicateTokenType type = [self getNextToken:NULL];
    self.position = position;
    
    return type;
}

- (PNPredicateTokenType)getNextToken:(id *)token {
    
    struct PNPRedicateNumericValue number = {0, 0.0f, 0.0f};
    PNPredicateTokenType type = PNPredicateToken.unknown;
    PNPredicateScannerState state = PNPredicateScanning.scanning;
    BOOL shouldContinueScanning = NO;
    id parsedToken = nil;
    for (;self.position < self.predicateLength; self.position++) {
        
        unichar code = _unicharPredicateFormat[self.position];
        if (state == PNPredicateScanning.scanning) {
            
            if ([self isControlCharCode:code]) { continue; }
            shouldContinueScanning = [self handleScanningState:&state usingCharCode:code tokenType:&type];
            if (state == PNPredicateScanning.identifier) { [self handleIdentifierScanningStart]; }
            else if (state == PNPredicateScanning.zero || state == PNPredicateScanning.integer || 
                     state == PNPredicateScanning.real) { 
                
                shouldContinueScanning = [self handleNumberScanning:&number withCharCode:code 
                                                              state:&state number:&parsedToken];
            }
            else if (state == PNPredicateScanning.stringDouble || state == PNPredicateScanning.stringSingle) {
                
                self.tokenPosition = self.position;
            }
        }
        else if (state == PNPredicateScanning.identifier) {
            
            shouldContinueScanning = [self handleIdentifierCharCode:code identifier:&parsedToken type:&type];
        }
        else if (state == PNPredicateScanning.zero || state == PNPredicateScanning.integer ||
                 state == PNPredicateScanning.real) {
            
            shouldContinueScanning = [self handleNumberScanning:&number withCharCode:code 
                                                          state:&state number:&parsedToken];
            if (!shouldContinueScanning) { type = PNPredicateToken.number; }
        }
        else if (state == PNPredicateScanning.stringDouble || state == PNPredicateScanning.stringSingle) {
            
            shouldContinueScanning = [self handleStringQuoteCharCode:code withState:&state string:&parsedToken];
            if (!shouldContinueScanning) { type = PNPredicateToken.string; }
        }
        else if (state == PNPredicateScanning.stringDoubleEscaped || state == PNPredicateScanning.stringSingleEscaped) {
            
            shouldContinueScanning = [self handleStringCharCode:code withState:&state string:&parsedToken];
            if (!shouldContinueScanning) { type = PNPredicateToken.string; }
        }
        else if (state == PNPredicateScanning.exclamation || state == PNPredicateScanning.equals || 
                 state == PNPredicateScanning.lessThan || state == PNPredicateScanning.greaterThan || 
                 state == PNPredicateScanning.bar || state == PNPredicateScanning.ampersand) {
            
            shouldContinueScanning = [self handleComparisonCharCode:code withState:&state type:&type];
        }
        if (!shouldContinueScanning) {
            
            if (parsedToken && token != NULL) { *token = parsedToken; }
            break;
        }
    }
    
    return (type == PNPredicateToken.unknown ? PNPredicateToken.end : type);
}

- (void)skipNextToken {
    
    [self getNextToken:NULL];
}

- (BOOL)handleScanningState:(out PNPredicateScannerState *)state usingCharCode:(unichar)code 
                  tokenType:(out PNPredicateTokenType *)type {
    
    BOOL shouldContinueScanning = YES;
    
    // Trying to fetch non-identifier token information if possible.
    struct PNPredicateTokenData tokenData = [self tokenDataForChar:code];
    if (tokenData.type == PNPredicateToken.unknown && [self isIdentifierCharCode:code]) {
        
        struct PNPredicateTokenData data = { code, PNPredicateToken.identifier, PNPredicateScanning.identifier};
        tokenData = data;
    }
    
    *type = tokenData.type;
    *state = tokenData.state;
    
    if (*state == PNPredicateScanning.leftParenthesis || *state == PNPredicateScanning.rightParenthesis ||
        *state == PNPredicateScanning.leftBracket || *state == PNPredicateScanning.rightBracket ||
        *state == PNPredicateScanning.leftBrace || *state == PNPredicateScanning.rightBrace ||
        *state == PNPredicateScanning.skip) {
        
        shouldContinueScanning = NO;
        self.position++;
    }
    
    return shouldContinueScanning;
}

- (void)handleIdentifierScanningStart {
     
    self.tokenPosition = self.position;
}

- (BOOL)handleIdentifierCharCode:(unichar)code identifier:(inout id *)token 
                            type:(out PNPredicateTokenType *)type {
    
    BOOL shouldContinueScanning = YES;
    BOOL isIdentifierCharCode = ([self isIdentifierCharCode:code] ||
                                 [self tokenDataForChar:code].type == PNPredicateToken.number);
    BOOL isEndOfString = (self.position == self.predicateLength - 1);
    if (!isIdentifierCharCode || isEndOfString) {
        
        if ([self isIdentifierCharCode:code] && isEndOfString) { self.position++; }
        *token = [NSString stringWithCharacters:[self tokenCharacters] length:[self tokenLength]];
        *type = [self tokenTypeForIdentifier:*token];
        shouldContinueScanning = NO;
    }
    
    return shouldContinueScanning;
}

- (BOOL)handleNumberScanning:(struct PNPRedicateNumericValue *)number withCharCode:(unichar)code 
                       state:(inout PNPredicateScannerState *)state number:(id *)token {
    
    BOOL shouldContinueScanning = YES;
    BOOL shouldReturnToken = YES;
    if (*state == PNPredicateScanning.scanning) { number->integerValue = code - '0'; }
    
    // Trying to fetch non-identifier token information if possible.
    struct PNPredicateTokenData tokenData = [self tokenDataForChar:code];
    if (*state == PNPredicateScanning.zero) {
        
        number->integerValue = 0;
        self.position--;
        *state = PNPredicateScanning.integer;
        shouldReturnToken = (self.position == self.predicateLength - 1);
        if (shouldReturnToken) { self.position++; }
    }
    else if (*state == PNPredicateScanning.integer || *state == PNPredicateScanning.real) {
        
        if (tokenData.type == PNPredicateToken.dot && *state == PNPredicateScanning.integer) {
            
            *state = PNPredicateScanning.real;
            number->realValue = number->integerValue;
            number->realValueFraction = 0.1f;
            shouldReturnToken = (self.position == self.predicateLength - 1);
            if (shouldReturnToken) { self.position++; }
        }
        else if (code >= '0' && code <= '9') {
            
            if (*state == PNPredicateScanning.real) {
                
                number->realValue += number->realValueFraction * (code - '0');
                number->realValueFraction *= 0.1f;
            }
            else { number->integerValue = (number->integerValue * 10 + code - '0'); }
            shouldReturnToken = (self.position == self.predicateLength - 1);
            if (shouldReturnToken) { self.position++; }
        }
    }
    
    if (shouldReturnToken) {
        
        if (*state == PNPredicateScanning.integer) { *token = [NSNumber numberWithUnsignedLong:number->integerValue]; }
        else { *token = [NSNumber numberWithDouble:number->realValue]; }
        shouldContinueScanning = NO;
    }
    
    return shouldContinueScanning;
}

- (BOOL)handleStringQuoteCharCode:(unichar)code withState:(inout PNPredicateScannerState *)state 
                           string:(id *)token {
    
    BOOL shouldContinueScanning = YES;
    if (code == '\\') {
        
        if (*state == PNPredicateScanning.stringDouble) { *state = PNPredicateScanning.stringDoubleEscaped; }
        else { *state = PNPredicateScanning.stringSingleEscaped; }
        *token = [NSMutableString stringWithCharacters:[self tokenCharacters] length:[self tokenLength]];
    }
    else if ((*state == PNPredicateScanning.stringDouble && code == '"') ||
             (*state == PNPredicateScanning.stringSingle && code == '\'')) {
        
        *token = [NSString stringWithCharacters:[self tokenCharacters] 
                                         length:([self tokenLength] + 1)];
        shouldContinueScanning = NO;
        self.position++;
    }
    
    return shouldContinueScanning;
}

- (BOOL)handleStringCharCode:(unichar)code withState:(inout PNPredicateScannerState *)state 
                      string:(id *)token {
    
    BOOL shouldContinueScanning = YES;
    if (*state == PNPredicateScanning.stringDoubleEscaped || *state == PNPredicateScanning.stringSingleEscaped) {
        
        if ((*state == PNPredicateScanning.stringDoubleEscaped && code == '"') || 
            (*state == PNPredicateScanning.stringSingleEscaped && code == '\'')) {
            
            [((NSMutableString *)*token) appendFormat:@"%C", code];
            if (*state == PNPredicateScanning.stringDoubleEscaped) {
                
                *state = PNPredicateScanning.stringDoubleEscapeBuffered;
            }
            else { *state = PNPredicateScanning.stringSingleEscapeBuffered; }
        }
    }
    else {
        
        if (code == '\\') {
            
            if (*state == PNPredicateScanning.stringDoubleEscapeBuffered) {
                
                *state = PNPredicateScanning.stringDoubleEscaped;
            }
            else { *state = PNPredicateScanning.stringSingleEscaped; }
        }
        else if ((*state == PNPredicateScanning.stringDoubleEscapeBuffered && code == '"') || 
                 (*state == PNPredicateScanning.stringSingleEscapeBuffered && code == '\'')) {
            
            shouldContinueScanning = NO;
            self.position++;
        }
        else { [((NSMutableString *)*token) appendFormat:@"%C", code]; }
    }
    
    return shouldContinueScanning;
}

- (BOOL)handleComparisonCharCode:(unichar)code withState:(inout PNPredicateScannerState *)state 
                            type:(PNPredicateTokenType *)type {
    
    BOOL shouldContinueScanning = YES;
    
    // Trying to fetch non-identifier token information if possible.
    struct PNPredicateTokenData tokenData = [self tokenDataForChar:code];
    if (tokenData.type != PNPredicateToken.unknown) {
        
        if (*state == PNPredicateScanning.exclamation) {
            
            if (tokenData.type == PNPredicateToken.equals) { *type = PNPredicateToken.notEquals; }
            else { *type = PNPredicateToken.NOT; }
            shouldContinueScanning = NO;
        }
        else if (*state == PNPredicateScanning.equals) {
            
            if (tokenData.type == PNPredicateToken.equals) { *type = PNPredicateToken.equals; }
            else if (tokenData.type == PNPredicateToken.lessThan) { *type = PNPredicateToken.greaterThanOrEqual; }
            else if (tokenData.type == PNPredicateToken.greaterThan) { *type = PNPredicateToken.lessThanOrEqual; }
            shouldContinueScanning = NO;
        }
        else if (*state == PNPredicateScanning.lessThan) {
            
            if (tokenData.type == PNPredicateToken.equals) { *type = PNPredicateToken.lessThanOrEqual; }
            else if (tokenData.type == PNPredicateToken.greaterThan) { *type = PNPredicateToken.NOT; }
            shouldContinueScanning = NO;
        }
        else if (*state == PNPredicateScanning.greaterThan) {
            
            if (tokenData.type == PNPredicateToken.equals) { *type = PNPredicateToken.greaterThanOrEqual; }
            shouldContinueScanning = NO;
        }
        else if (*state == PNPredicateScanning.ampersand) {
            
            if (tokenData.type == PNPredicateToken.ampersand) { *type = PNPredicateToken.AND; }
            shouldContinueScanning = NO;
        }
        else if (*state == PNPredicateScanning.bar) {
            
            if (tokenData.type == PNPredicateToken.bar) { *type = PNPredicateToken.OR; }
            shouldContinueScanning = NO;
        }
    }
    else  { shouldContinueScanning = NO; }
    if (!shouldContinueScanning && [self isComparisonToken:tokenData.type]) { self.position++; }
    
    return shouldContinueScanning;
}


#pragma mark - Misc

- (void)prepareScanner {
    
    self.predicateLength = self.predicateExpression.length;
    _unicharPredicateFormat = malloc(sizeof(unichar) * self.predicateLength);
    [self.predicateExpression getCharacters:_unicharPredicateFormat
                                      range:NSMakeRange(0, self.predicateLength)];
}

- (void)prepareTokensTable {
    
    [self bind:'(' atIndex:0 toToken:PNPredicateToken.leftParenthesis state:PNPredicateScanning.leftParenthesis];
    [self bind:')' atIndex:1 toToken:PNPredicateToken.rightParenthesis state:PNPredicateScanning.rightParenthesis];
    [self bind:'[' atIndex:2 toToken:PNPredicateToken.leftBracket state:PNPredicateScanning.leftBracket];
    [self bind:']' atIndex:3 toToken:PNPredicateToken.rightBracket state:PNPredicateScanning.rightBracket];
    [self bind:'{' atIndex:4 toToken:PNPredicateToken.leftBrace state:PNPredicateScanning.leftBrace];
    [self bind:'}' atIndex:5 toToken:PNPredicateToken.rightBrace state:PNPredicateScanning.rightBrace];
    [self bind:'!' atIndex:6 toToken:PNPredicateToken.exclamation state:PNPredicateScanning.exclamation];
    [self bind:'=' atIndex:7 toToken:PNPredicateToken.equals state:PNPredicateScanning.equals];
    [self bind:'<' atIndex:8 toToken:PNPredicateToken.lessThan state:PNPredicateScanning.lessThan];
    [self bind:'>' atIndex:9 toToken:PNPredicateToken.greaterThan state:PNPredicateScanning.greaterThan];
    [self bind:'.' atIndex:10 toToken:PNPredicateToken.dot state:PNPredicateScanning.skip];
    [self bind:',' atIndex:11 toToken:PNPredicateToken.comma state:PNPredicateScanning.skip];
    [self bind:'~' atIndex:12 toToken:PNPredicateToken.tilde state:PNPredicateScanning.skip];
    [self bind:'|' atIndex:13 toToken:PNPredicateToken.bar state:PNPredicateScanning.bar];
    [self bind:'&' atIndex:14 toToken:PNPredicateToken.ampersand state:PNPredicateScanning.ampersand];
    [self bind:'^' atIndex:15 toToken:PNPredicateToken.caret state:PNPredicateScanning.skip];
    [self bind:'+' atIndex:16 toToken:PNPredicateToken.plus state:PNPredicateScanning.skip];
    [self bind:'-' atIndex:17 toToken:PNPredicateToken.minus state:PNPredicateScanning.skip];
    [self bind:'/' atIndex:18 toToken:PNPredicateToken.slash state:PNPredicateScanning.skip];
    [self bind:'*' atIndex:19 toToken:PNPredicateToken.asterisk state:PNPredicateScanning.skip];
    [self bind:'"' atIndex:20 toToken:PNPredicateToken.stringDouble state:PNPredicateScanning.stringDouble];
    [self bind:'\'' atIndex:21 toToken:PNPredicateToken.stringSingle state:PNPredicateScanning.stringSingle];
    [self bind:'0' atIndex:22 toToken:PNPredicateToken.number state:PNPredicateScanning.zero];
    [self bind:'1' atIndex:23 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'2' atIndex:24 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'3' atIndex:25 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'4' atIndex:26 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'5' atIndex:27 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'6' atIndex:28 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'7' atIndex:29 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'8' atIndex:30 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
    [self bind:'9' atIndex:31 toToken:PNPredicateToken.number state:PNPredicateScanning.integer];
}

- (void)bind:(unichar)character atIndex:(NSUInteger)index toToken:(PNPredicateTokenType)type 
       state:(PNPredicateScannerState)state {
    
    struct PNPredicateTokenData token = {character, type, state};
    _tokenTable[index] = token;
}

- (struct PNPredicateTokenData)tokenDataForChar:(unichar)character {
    
    struct PNPredicateTokenData data = { ' ', PNPredicateToken.unknown, PNPredicateScanning.skip};
    for (NSUInteger tokenDataIdx = 0; tokenDataIdx < kPNScannerTokenTableSize; tokenDataIdx++) {
        
        if (_tokenTable[tokenDataIdx].token == character) { data = _tokenTable[tokenDataIdx]; }
        if (data.type != PNPredicateToken.unknown) { break; }
    }
    
    return data;
}

- (BOOL)isControlCharCode:(unichar)code {
    
    static NSCharacterSet *_controlCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ 
        
        NSMutableCharacterSet *charSet = [NSMutableCharacterSet controlCharacterSet];
        [charSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _controlCharacterSet = [charSet copy]; 
    });
    
    return [_controlCharacterSet characterIsMember:code];
}

- (BOOL)isIdentifierCharCode:(unichar)code {
    
    static NSCharacterSet *_identifierCharacterSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _identifierCharacterSet = [NSCharacterSet letterCharacterSet]; });
    
    return [_identifierCharacterSet characterIsMember:code];
}

- (PNPredicateTokenType)tokenTypeForIdentifier:(NSString *)identifier {
    
    NSString *lowerCaseIdentifier = [identifier lowercaseString];
    PNPredicateTokenType type = PNPredicateToken.identifier;
    if ([lowerCaseIdentifier isEqualToString:@"and"]) { type = PNPredicateToken.AND; }
    else if ([lowerCaseIdentifier isEqualToString:@"or"]) { type = PNPredicateToken.OR; }
    else if ([lowerCaseIdentifier isEqualToString:@"not"]) { type = PNPredicateToken.NOT; }
    else if ([lowerCaseIdentifier isEqualToString:@"between"]) { type = PNPredicateToken.between; }
    else if ([lowerCaseIdentifier isEqualToString:@"beginswith"]) { type = PNPredicateToken.beginsWith; }
    else if ([lowerCaseIdentifier isEqualToString:@"contains"]) { type = PNPredicateToken.contains; }
    else if ([lowerCaseIdentifier isEqualToString:@"endswith"]) { type = PNPredicateToken.endsWith; }
    else if ([lowerCaseIdentifier isEqualToString:@"in"]) { type = PNPredicateToken.IN; }
    else if ([lowerCaseIdentifier isEqualToString:@"like"]) { type = PNPredicateToken.like; }
    
    return type;
}

- (PNComparisonOperatorType)comparisonOperationForToken:(PNPredicateTokenType)token {
    
    PNComparisonOperatorType type = PNComparisonEqualToType;
    if (token == PNPredicateToken.lessThan) { type = PNComparisonLessThanType; }
    else if (token == PNPredicateToken.lessThanOrEqual) { type = PNComparisonLessThanOrEqualType; }
    else if (token == PNPredicateToken.notEquals) { type = PNComparisonNotEqualToType; }
    else if (token == PNPredicateToken.greaterThan) { type = PNComparisonGreaterThanType; }
    else if (token == PNPredicateToken.greaterThanOrEqual) { type = PNComparisonGreaterThanOrEqualToType; }
    else if (token == PNPredicateToken.beginsWith) { type = PNComparisonBeginsWithType; }
    else if (token == PNPredicateToken.contains) { type = PNComparisonContainsType; }
    else if (token == PNPredicateToken.endsWith) { type = PNComparisonEndsWithType; }
    else if (token == PNPredicateToken.IN) { type = PNComparisonInType; }
    else if (token == PNPredicateToken.like) { type = PNComparisonLikeType; }
    
    return type;
}

- (BOOL)isComparisonToken:(PNPredicateTokenType)token {
    
    return (token == PNPredicateToken.lessThan || token == PNPredicateToken.lessThanOrEqual ||
            token == PNPredicateToken.equals || token == PNPredicateToken.notEquals ||
            token == PNPredicateToken.greaterThan || token == PNPredicateToken.greaterThanOrEqual ||
            token == PNPredicateToken.beginsWith || token == PNPredicateToken.contains ||
            token == PNPredicateToken.endsWith || token == PNPredicateToken.IN ||
            token == PNPredicateToken.like);
}

- (PNPredicateTokenType)operationForToken:(PNPredicateTokenType)token {
    
    PNPredicateTokenType type = PNExpressionOperation.add;
    if (token == PNPredicateToken.minus) { type = PNExpressionOperation.substract; }
    else if (token == PNPredicateToken.bar) { type = PNExpressionOperation.bitwiseOR; }
    else if (token == PNPredicateToken.ampersand) { type = PNExpressionOperation.bitwiseAND; }
    else if (token == PNPredicateToken.caret) { type = PNExpressionOperation.bitwiseXOR; }
    else if (token == PNPredicateToken.slash) { type = PNExpressionOperation.divide; }
    else if (token == PNPredicateToken.asterisk) { type = PNExpressionOperation.multiply; }
    
    return type;
}

- (BOOL)isOperationToken:(PNPredicateTokenType)token {
    
    return (token == PNPredicateToken.plus || token == PNPredicateToken.minus ||
            token == PNPredicateToken.bar || token == PNPredicateToken.ampersand ||
            token == PNPredicateToken.caret || token == PNPredicateToken.slash ||
            token == PNPredicateToken.asterisk);
}

- (const unichar *)tokenCharacters {
    
    return (_unicharPredicateFormat + self.tokenPosition);
}

- (NSUInteger)tokenLength {
    
    return (self.position - self.tokenPosition);
}

- (NSString *)stringifiedTokenType:(PNPredicateTokenType)type {
    
    static NSDictionary *_tokenTypeMappingTable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _tokenTypeMappingTable = @{
            @(PNPredicateToken.end):@"EOP",@(PNPredicateToken.unknown):@"unknown",
            @(PNPredicateToken.leftParenthesis):@"(", @(PNPredicateToken.rightParenthesis):@")", 
            @(PNPredicateToken.leftBracket):@"[", @(PNPredicateToken.rightBracket):@"]",
            @(PNPredicateToken.leftBrace):@"{", @(PNPredicateToken.rightBrace):@"}",
            @(PNPredicateToken.exclamation):@"!", @(PNPredicateToken.equals):@"=",
            @(PNPredicateToken.notEquals):@"!=", @(PNPredicateToken.lessThan):@"<", 
            @(PNPredicateToken.lessThanOrEqual):@"<=", @(PNPredicateToken.greaterThan):@">", 
            @(PNPredicateToken.greaterThanOrEqual):@">=", @(PNPredicateToken.dot):@".",
            @(PNPredicateToken.comma):@",", @(PNPredicateToken.tilde):@"~", 
            @(PNPredicateToken.bar):@"|", @(PNPredicateToken.ampersand):@"&", @(PNPredicateToken.caret):@"^",
            @(PNPredicateToken.plus):@"+", @(PNPredicateToken.minus):@"-",
            @(PNPredicateToken.slash):@"/", @(PNPredicateToken.asterisk):@"*", @(PNPredicateToken.number):@"#",
            @(PNPredicateToken.string): @"string", @(PNPredicateToken.stringDouble):@"\"", 
            @(PNPredicateToken.stringSingle):@"'", @(PNPredicateToken.identifier):@"identifier",
            @(PNPredicateToken.AND):@"and", @(PNPredicateToken.OR):@"OR", @(PNPredicateToken.NOT):@"NOT", 
            @(PNPredicateToken.between):@"between", @(PNPredicateToken.beginsWith):@"beginswith", 
            @(PNPredicateToken.contains):@"contains", @(PNPredicateToken.endsWith):@"endswith", 
            @(PNPredicateToken.IN):@"in", @(PNPredicateToken.like):@"like"
        };
    });
    
    return _tokenTypeMappingTable[@(type)];
}

#pragma mark -


@end
