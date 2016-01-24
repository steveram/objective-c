/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNPredicate+Protected.h"
#import "PNPredicate+Scanner.h"


#pragma mark Interface implementation

@implementation PNPredicate


#pragma mark - Initialization and Configuration

+ (instancetype)predicateWithFormat:(NSString *)format, ... {
    
    va_list arguments;
    va_start(arguments, format);
    NSMutableArray *argumentsArray = [NSMutableArray new];
    id argument;
    while ((argument = va_arg(arguments, id))) {
        
        if (argument != nil) { [argumentsArray addObject:argument]; }
        else { break; }
    }
    
    return [self predicateWithFormat:format argumentArray:argumentsArray];
}

+ (PNPredicate *)predicateWithFormat:(NSString *)format argumentArray:(NSArray *)arguments {

    return [self predicateFromStringExpression:[self substitutedString:format withValues:arguments]];
}

+ (instancetype)predicateFromStringExpression:(NSString *)expression; {
    
    return [[[self alloc] initFromStringExpression:expression] predicate];
}

- (instancetype)initFromStringExpression:(NSString *)expression {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _predicateExpression = [expression copy];
    }
    
    return self;
}

#pragma mark - Translation

- (NSString *)stringValue {
    
    NSAssert(0, @"%s shoul be implemented in subclasses.", __PRETTY_FUNCTION__);
    return nil;
}

- (NSString *)stringValueWithOutParenthesis {
    
    return [self stringValue];
}


#pragma mark - Misc

+ (NSString *)substitutedString:(NSString *)string withValues:(NSArray *)values {
    
    NSMutableString *targetFormat = [NSMutableString stringWithString:string];
    NSUInteger tokenIdx = 0;
    NSRange tokenRange = NSMakeRange(NSNotFound, 0);
    do {
        
        tokenRange = [targetFormat rangeOfString:@"%@"];
        if (tokenRange.location != NSNotFound) {
            
            id value = values[tokenIdx];
            NSString *stringifiedValue = nil;
            if ([value isKindOfClass:NSArray.class]) {
                
                stringifiedValue = [NSString stringWithFormat:@"[%@]", 
                                    [(NSArray *)value componentsJoinedByString:@","]];
            }
            else if ([values[tokenIdx] respondsToSelector:@selector(count)]) {
                
                NSData *valueData = [NSJSONSerialization dataWithJSONObject:values[tokenIdx]
                                                                    options:(NSJSONWritingOptions)0
                                                                      error:nil];
                if (valueData) { 
                    
                    stringifiedValue = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
                }
            }
            else { stringifiedValue = [NSString stringWithFormat:@"%@", values[tokenIdx]]; }
            [targetFormat replaceCharactersInRange:tokenRange withString:(stringifiedValue?: @"")];
            tokenIdx++;
        }
    } while (tokenRange.location != NSNotFound);
    
    return targetFormat;
}


#pragma mark - Misc

- (void)dealloc {
    
    free(_unicharPredicateFormat);
}

#pragma mark -


@end
