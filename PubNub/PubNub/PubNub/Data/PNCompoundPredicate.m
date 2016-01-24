/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNCompoundPredicate+Protected.h"
#import "PNPredicate+Protected.h"


#pragma mark Interface implementation

@implementation PNCompoundPredicate


#pragma mark - Initialization and Configuration

+ (instancetype)andPredicateWithSubpredicates:(NSArray<PNPredicate *> *)subpredicates {
    
    return [[self alloc] initWithCompoundType:PNAndPredicateCompoundType subpredicates:subpredicates];
}

+ (instancetype)orPredicateWithSubpredicates:(NSArray<PNPredicate *> *)subpredicates {
    
    return [[self alloc] initWithCompoundType:PNOrPredicateCompoundType subpredicates:subpredicates];
}

+ (instancetype)notPredicateWithSubpredicate:(PNPredicate *)predicate {
    
    return [[self alloc] initWithCompoundType:PNNotPredicateCompoundType subpredicates:@[predicate]];
}

- (instancetype)initWithCompoundType:(PNPredicateCompoundType)type 
                       subpredicates:(NSArray<PNPredicate *> *)subpredicates {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _compoundPredicateType = type;
        _subpredicates = subpredicates;
        
        NSUInteger expectedCount = (type != PNNotPredicateCompoundType ? 2 : 1);
        if (expectedCount != subpredicates.count) {
            
            [NSException raise:NSInvalidArgumentException format:@"Wrong number of parameters."
             "Exprected %@, but got %@", @(expectedCount), @(subpredicates.count)];
        }
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
    
    NSMutableString *value = [NSMutableString new];
    NSString *operator = @"!";
    if (self.compoundPredicateType == PNAndPredicateCompoundType || 
        self.compoundPredicateType == PNOrPredicateCompoundType) {
        
        NSString *format = @"%@ %@ %@";
        if (encloseInParenthesis) { format = @"(%@ %@ %@)"; }
        operator = (self.compoundPredicateType == PNAndPredicateCompoundType ? @"&&" : @"||");
        [value appendFormat:format, [self.subpredicates[0] stringValue],
         operator, [self.subpredicates[1] stringValue]];
    }
    else if (self.compoundPredicateType == PNNotPredicateCompoundType) {
        
        [value appendFormat:@"%@(%@)", operator, [self.subpredicates[0] stringValue]];
    }
    
    return [value copy];
}

#pragma mark -


@end
