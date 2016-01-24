/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNPredicate+Protected.h"
#import "PNComparisonPredicate.h"
#import "PNExpression+Protected.h"


#pragma mark Private interface declaration

@interface PNComparisonPredicate ()


#pragma mark - Properties

@property (nonatomic, strong) PNExpression *leftHandExpression;
@property (nonatomic, strong) PNExpression *rightHandExpression;
@property (nonatomic, assign) PNComparisonOperatorType comparisonOperationType;


#pragma mark - Initialization and Configuration

/**
 @brief      Initialize comparison predicate with predefined operation type.
 @discussion This approach require more code but eliminates possible type in operations and 
             variables declaration in predicate format string (\b PNPredicate class method).
 
 @param leftExpression  Reference on object which will be on  the left side of operand.
                        \b Important: this property can be only one of these types: \c NSString, 
                        \c NSNumber.
 @param rightExpression Reference on object which will be on the right side of operand.
                        \b Important: this property can be only one of these types: \c NSString, 
                        \c NSNumber, \c NSArray.
 @param type            Compare operand type.
 
 @return Initialized and ready to use predicate instance.
 */
- (instancetype)initWithLeftExpression:(id)leftExpression rightExpression:(id)rightExpression
                                  type:(PNComparisonOperatorType)type;


#pragma mark - Misc

/**
 @brief  Depending on comparison operator type there is requirement to
         add some tokens to right-hand expression string.
 
 @return Updated string which represent right-hand expression for 
         concrete compare operation.
 */
- (NSString *)preparedRightHandExpression;

/**
 @brief  Translate enum field to string.
 
 @return Stringified comparison operation type.
 */
- (NSString *)stringifiedOperator;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNComparisonPredicate


#pragma mark - Initialization and Configuration

+ (instancetype)predicateWithLeftExpression:(id)leftExpression rightExpression:(id)rightExpression
                                       type:(PNComparisonOperatorType)type {
    
    return [[self alloc] initWithLeftExpression:leftExpression 
                                rightExpression:rightExpression type:type];
}

- (instancetype)initWithLeftExpression:(id)leftExpression rightExpression:(id)rightExpression
                                  type:(PNComparisonOperatorType)type {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _leftHandExpression = leftExpression;
        _rightHandExpression = rightExpression;
        _comparisonOperationType = type;
    }
    
    return self;
}


#pragma mark - Serialization

- (NSString *)stringValue {
    
    return [NSString stringWithFormat:@"%@%@%@", 
            [self.leftHandExpression stringValue], 
            [self stringifiedOperator], [self preparedRightHandExpression]];
}


#pragma mark - Misc

- (NSString *)preparedRightHandExpression {
    
    NSString *value = [self.rightHandExpression stringValue];
    if (self.rightHandExpression.valueType == NSString.class) {
        
        if (value.length >= 2) {
            
            if ([value rangeOfString:@"*"].location == 1) {
                
                NSRange range = NSMakeRange(1, 1);
                value = [value stringByReplacingCharactersInRange:range withString:@"%"];
            }
            if ([value rangeOfString:@"*" options:NSBackwardsSearch].location == (value.length - 2)) {
                
                NSRange range = NSMakeRange((value.length - 2), 1);
                value = [value stringByReplacingCharactersInRange:range withString:@"%"];
            }
            if (self.comparisonOperationType == PNComparisonBeginsWithType ||
                self.comparisonOperationType == PNComparisonContainsType) {
                
                NSRange range = NSMakeRange((value.length - 1), 0);
                value = [value stringByReplacingCharactersInRange:range withString:@"%"];
            }
            if (self.comparisonOperationType == PNComparisonEndsWithType ||
                self.comparisonOperationType == PNComparisonContainsType) {
                
                NSRange range = NSMakeRange(1, 0);
                value = [value stringByReplacingCharactersInRange:range withString:@"%"];
            }
        }
    }
    
    return value;
}

- (NSString *)stringifiedOperator {
    
    NSString *operator = nil;
    switch (self.comparisonOperationType) {
        case PNComparisonLessThanType:
            
            operator = @"<";
            break;
        case PNComparisonLessThanOrEqualType:
            
            operator = @"<=";
            break;
        case PNComparisonEqualToType:
            
            operator = @"==";
            break;
        case PNComparisonNotEqualToType:
            
            operator = @"!=";
            break;
        case PNComparisonGreaterThanType:
            
            operator = @">";
            break;
        case PNComparisonGreaterThanOrEqualToType:
            
            operator = @">=";
            break;
        case PNComparisonLikeType:
        case PNComparisonBeginsWithType:
        case PNComparisonContainsType:
        case PNComparisonEndsWithType:
            
            operator = @" like ";
            break;
        case PNComparisonInType:
            
            operator = @" in ";
            break;
    }
    
    return operator;
}

#pragma mark -


@end
