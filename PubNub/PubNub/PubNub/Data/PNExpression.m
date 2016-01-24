/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNExpression+Protected.h"
#import "PNPredicate+Protected.h"
#import "PNOperationPredicate.h"


#pragma mark Extern

const struct PNExpressionOperationStructure PNExpressionOperation = {
    .negate = 0, .add = 1, .substract = 2, .multiply = 3, .divide = 4, 
    .bitwiseNOT = 5, .bitwiseOR = 6, .bitwiseAND = 7, .bitwiseXOR = 8
};

const struct PNExpressionValueTypeStructure PNExpressionValue = {
    .constant = 0,
    .keypath = 1, .firstIndex = 2, .lastIndex = 3,
    .operation = 4
};


#pragma mark - Interface implementation

@implementation PNExpression


#pragma mark - Initialization and Configuration

+ (nullable instancetype)expressionWithFormat:(NSString *)expression, ... {
    
    va_list arguments;
    va_start(arguments, expression);
    NSMutableArray *argumentsArray = [NSMutableArray new];
    id argument;
    while ((argument = va_arg(arguments, id))) {
        
        if (argument != nil) { [argumentsArray addObject:argument]; }
        else { break; }
    }
    va_end(arguments);
    
    
    return [self expressionWithFormat:expression arguments:argumentsArray];
}

+ (nullable instancetype)expressionWithFormat:(NSString *)expression arguments:(NSArray *)arguments {
    
    // Use predicate constructor to build PNOperationPredicate 
    // from user-provided format string.
    PNExpression *exression = nil;
    PNPredicate *predidate = [PNPredicate predicateWithFormat:expression argumentArray:arguments];
    if ([predidate isKindOfClass:PNOperationPredicate.class]) {
        
        exression = ((PNOperationPredicate *)predidate).expression;
    }
    else {
        
        [NSException raise:NSInvalidArgumentException 
                    format:@"Format string parsing failed: \"%@\" because of: %@",
         predidate.predicateExpression, @"Expression shouldn't contain comparison or compound tokens."];
    }
    
    return exression;
}

+ (instancetype)expressionWithType:(PNExpressionValueType)type value:(id)value {
    
    return [[self alloc] initExpression:type withValue:value];
}

+ (instancetype)expressionForConstantValue:(id)value {
    
    if (value) [self throwIfConstantValueUnsupported:value];
    if (!value) { value = @"''"; }
    
    return [[self alloc] initWithConstantValue:value];
}

+ (instancetype)expressionForKeyPath:(NSString *)string {
    
    return [self expressionWithType:PNExpressionValue.keypath value:string];
}

+ (PNExpression *)expressionWithOperation:(PNExpressionOperationType)type arguments:(NSArray *)arguments {
    
    NSUInteger expectedCount = (type == PNExpressionOperation.negate || type == PNExpressionOperation.bitwiseNOT ? 1 : 2);
    if (expectedCount != arguments.count) {
        
        [NSException raise:NSInvalidArgumentException format:@"Wrong number of parameters for \"%@\". "
         "Exprected %@, but got %@", [self stringifiedOperation:type], @(expectedCount), @(arguments.count)];
    }
    
    return [[self alloc] initWithOperation:type arguments:arguments];
}

- (instancetype)initWithConstantValue:(id)value {
    
    // Check whether initialization was successful or not.
    if ((self = [self initExpression:PNExpressionValue.constant withValue:value])) {
        
        if ([value isKindOfClass:NSString.class]) { _valueType = NSString.class; }
        else if ([value isKindOfClass:NSNumber.class]) { _valueType = NSNumber.class; }
        else if ([value isKindOfClass:NSArray.class]) { _valueType = NSArray.class; }
        else if ([value isKindOfClass:NSDictionary.class]) { _valueType = NSDictionary.class; }
        if (_value == NSString.class) {
            
            _value = [_value stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
        }
    }
    
    return self;
}

- (instancetype)initWithOperation:(PNExpressionOperationType)type arguments:(NSArray *)arguments {
    
    // Check whether initialization was successful or not.
    if ((self = [self initExpression:PNExpressionValue.operation withValue:arguments])) {
        
        _operationType = type;
    }
    
    return self;
}

- (instancetype)initExpression:(PNExpressionValueType)type withValue:(id)value {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _type = type;
        if (type != PNExpressionValue.constant && type != PNExpressionValue.firstIndex &&
            type != PNExpressionValue.lastIndex) { 
            
            if ([value isKindOfClass:NSArray.class]) { _arguments = value; }
            else { _arguments = @[value]; }
        }
        else { _value = value; }
        
        if (_type == PNExpressionValue.firstIndex || _type == PNExpressionValue.lastIndex) {
            
            [self normalizeValueIfRequired];
            _type = PNExpressionValue.constant;
        }
    }
    
    return self;
}


#pragma mark - Serialization

- (NSString *)stringValue {
    
    return [self stringValueWithParenthesis:YES];
}
- (NSString *)stringValueWithOutParenthesis {
    
    return [self stringValueWithParenthesis:NO];
}

- (NSString *)stringValueWithParenthesis:(BOOL)encloseInParenthesis {
    
    NSMutableString *expression = [NSMutableString new];
    if (self.type == PNExpressionValue.constant) {
        
        [expression setString:[self stringifiedConstant]];
    }
    else if (self.type == PNExpressionValue.firstIndex || 
             self.type == PNExpressionValue.lastIndex) {
    }
    else if (self.type == PNExpressionValue.keypath) {
        
        [expression setString:[self keyPath]];
    }
    else if (self.type == PNExpressionValue.operation) {
        
        NSString *format = [self.class expressionFormatForOperation:self.operationType];
        if (!encloseInParenthesis) {
            
            NSCharacterSet *trimmedSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
            format = [format stringByTrimmingCharactersInSet:trimmedSet]; 
        }
        [expression setString:[NSString stringWithFormat:format,
                               [[self.arguments firstObject] stringValue], [[self.arguments lastObject] stringValue]]];
    }
    
    return [expression copy];
}

- (NSString *)stringifiedConstant {
    
    NSString *stringifiedConstant = nil;
    if (self.valueType == NSDictionary.class) {
        
        stringifiedConstant = [self stringifiedDictionaryValue:self.value];
    }
    else if (self.valueType == NSArray.class) {
        
        stringifiedConstant = [self stringifiedArrayValue:self.value];
    }
    else if (self.valueType == NSString.class) {
        
        stringifiedConstant = [self quotedString:self.value]; 
    }
    else {
        
        stringifiedConstant = [NSString stringWithFormat:@"%@", 
                               [self unwrapValueIfRequired:self.value]];
    }
    
    return stringifiedConstant;
}

- (id)unwrapValueIfRequired:(id)value {
    
    return ([value isKindOfClass:self.class] ? [((PNExpression *)value) stringValue] : value);
}

- (NSString *)stringifiedArrayValue:(NSArray *)value {
    
    NSMutableString *array = [NSMutableString stringWithString:@"["];
    [value enumerateObjectsUsingBlock:^(id  entry, NSUInteger entryIdx, __unused BOOL *entriesEnumeratorStop) {
        
        [array appendString:[self unwrapValueIfRequired:entry]];
        if (entryIdx + 1 < value.count) { [array appendString:@","]; }
    }];
    [array appendString:@"]"];
    
    return [array copy];
}

- (NSString *)stringifiedDictionaryValue:(NSDictionary *)value {
    
    NSData *valueData = [NSJSONSerialization dataWithJSONObject:value
                                                        options:(NSJSONWritingOptions)0
                                                          error:nil];
    return (valueData ? [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding] : nil);
}

- (NSString *)keyPath {
    
    NSMutableString *keyPath = [NSMutableString new];
    [self.arguments enumerateObjectsUsingBlock:^(id argument, __unused NSUInteger argumentIdx, 
                                                 __unused BOOL *argumentsEnumeratorStop) {
        
        BOOL isKey = NO;
        NSString *element = nil;
        if ([argument isKindOfClass:self.class]) {
            
            Class valueType = ((PNExpression *)argument).valueType;
            if (valueType != nil) {
                
                if (valueType == NSString.class) {
                    
                    element = [NSString stringWithFormat:@"[%@]", 
                               [self unwrapValueIfRequired:argument]];
                    isKey = YES;
                }
            }
            else { element = [self unwrapValueIfRequired:argument]; }
        }
        [keyPath appendFormat:@"%@%@", (keyPath.length && !isKey ? @"." : @""), (element?: argument)];
    }];
    
    return [keyPath copy];
}


#pragma mark - Misc

- (void)normalizeValueIfRequired {
        
    if ([_value isKindOfClass:self.class]) {
        
        PNExpression *expressionValue = (PNExpression *)_value;
        if ([(expressionValue.value?: expressionValue.arguments) isKindOfClass:NSArray.class]) {
            
            _value = (expressionValue.value?: expressionValue.arguments);
            [self normalizeValueIfRequired];
        }
        else {
            
            _value = (expressionValue.value?: expressionValue.arguments);
        }
    }
    else if ([_value isKindOfClass:NSArray.class]) {
        
        NSArray *arrayValue = (NSArray *)_value;
        if ([arrayValue[0] isKindOfClass:self.class] && arrayValue.count == 1) { _value = arrayValue[0]; }
        else {
            
            if (_type == PNExpressionValue.firstIndex) { _value = [(NSArray *)_value firstObject]; }
            else { _value = [(NSArray *)_value lastObject]; }
        }
        [self normalizeValueIfRequired];
    }
}

- (NSString *)quotedString:(NSString *)string {
    
    NSString *quotedString = string;
    if (string.length > 0) {
        
        unichar prefixCode = [string characterAtIndex:0];
        NSString *suffix = [NSString stringWithFormat:@"%c", prefixCode];
        BOOL wrapRequired = (prefixCode != '\'' && prefixCode != '"');
        if (!wrapRequired) { wrapRequired = ![string hasSuffix:suffix]; }
        if (wrapRequired) {
            
            NSString *quote = (prefixCode == '\'' ? @"'" : @"\"");
            quotedString = [NSString stringWithFormat:@"%@%@%@", quote, string, quote];
        }
    }
    
    return quotedString;
}

+ (NSString *)stringifiedOperation:(PNExpressionOperationType)type {
    
    static NSDictionary *_operationsMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _operationsMap = @{@(PNExpressionOperation.negate):@"-", 
                           @(PNExpressionOperation.add):@"+", @(PNExpressionOperation.substract):@"-", 
                           @(PNExpressionOperation.multiply):@"*", @(PNExpressionOperation.divide):@"/", 
                           @(PNExpressionOperation.bitwiseNOT):@"~", @(PNExpressionOperation.bitwiseOR):@"|",
                           @(PNExpressionOperation.bitwiseAND):@"&", @(PNExpressionOperation.bitwiseXOR):@"^"};
    });
    
    return _operationsMap[@(type)];
}

+ (NSString *)expressionFormatForOperation:(PNExpressionOperationType)type {
    
    NSString *expression = [NSString stringWithFormat:@"(%@%%@)", [self stringifiedOperation:type]];
    if (type != PNExpressionOperation.negate && type != PNExpressionOperation.bitwiseNOT) {
        
        expression = [NSString stringWithFormat:@"(%%@%@%%@)", [self stringifiedOperation:type]];
    }
    
    return expression;
}

+ (void)throwIfConstantValueUnsupported:(id)value {
    
    if (![self isConstantValueSupported:value]) { 
        
        [NSException raise:NSInvalidArgumentException 
                    format:@"Invali argument type or content: %@", value];
    }
}

+ (BOOL)isConstantValueSupported:(id)value {
    
    __block BOOL isValidConstantValue = YES;
    if ([value isKindOfClass:self]) {
        
        PNExpression *expressionValue = (PNExpression *)value;
        id valueForVerification = (expressionValue.value?: expressionValue.arguments);
        isValidConstantValue = [self isConstantValueSupported:valueForVerification];
    }
    else if (![value isKindOfClass:NSString.class] && ![value isKindOfClass:NSNumber.class]) {
        
        if ([value isKindOfClass:NSArray.class]) {
            
            NSArray *arrayValue = (NSArray *)value;
            [arrayValue enumerateObjectsUsingBlock:^(id element, __unused NSUInteger elementIdx,
                                                     __unused BOOL *elementsEnumeratorStop) {
                
                if ([value isKindOfClass:self]) {
                    
                    PNExpression *expressionValue = (PNExpression *)element;
                    id valueForVerification = (expressionValue.value?: expressionValue.arguments);
                    isValidConstantValue = [self isConstantValueSupported:valueForVerification];
                }
                else { isValidConstantValue = [self isConstantValueSupported:element]; }
                *elementsEnumeratorStop = !isValidConstantValue;
            }];
        }
        else { isValidConstantValue = [NSJSONSerialization isValidJSONObject:value]; }
    }
    
    return isValidConstantValue;
}

#pragma mark -


@end
