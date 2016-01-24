/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNOperationPredicate.h"
#import "PNExpression+Protected.h"


#pragma mark Private interface declaration

@interface PNOperationPredicate ()


#pragma mark - Properties

@property (strong) PNExpression *expression;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize predicate using operation expression.
 
 @param expression Representation of mathematic operation which should be wrapped
                   into predicate.
 
 @return Initialized and ready to use predicate instance.
 */
- (instancetype)initWithExpression:(PNExpression *)expression;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNOperationPredicate


#pragma mark - Initialization and Configuration

+ (instancetype)operationPredicateWithExpression:(PNExpression *)expression {
    
    return [[self alloc] initWithExpression:expression];
}

- (instancetype)initWithExpression:(PNExpression *)expression {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _expression = expression;
    }
    
    return self;
}


#pragma mark - Translation

- (NSString *)stringValue {
    
    return [self stringValueWithParenthesis:YES];
}

- (NSString *)stringValueWithOutParenthesis {
    
    return [self stringValueWithParenthesis:NO];
}

- (NSString *)stringValueWithParenthesis:(BOOL)encloseInParenthesis {
    
    return (encloseInParenthesis ? [self.expression stringValue] :
            [self.expression stringValueWithOutParenthesis]);
}

#pragma mark - 


@end
