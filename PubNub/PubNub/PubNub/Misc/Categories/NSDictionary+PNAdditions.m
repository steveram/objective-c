//
//  NSDictionary+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSDictionary+PNAdditions.h"


#pragma mark Private interface declaration

@interface NSDictionary (PNAdditionsPrivate)


#pragma mark - Instance methods

/**
 Method allow to check on nested objects whether valid dictionary has been provided for state or not.

 @param isFirstLevelNesting
 If set to \c YES, then values will be checked to be simple type in other case dictionary is allowed.

 @return \c YES if provided dictionary conforms to the requirements.
*/
- (BOOL)pn_isValidState:(BOOL)isFirstLevelNesting;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation NSDictionary (PNAdditions)


#pragma mark - Class methods

+ (NSArray *)pn_topLevelKeysFromList:(NSArray *)keyPaths {
    
    NSMutableArray *paths = nil;
    if ([keyPaths count] > 1) {
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:YES];
        paths = [[keyPaths sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
        [[paths copy] enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger keyPathIdx,
                                                   BOOL *keyPathEnumeratorStop) {
            
            NSUInteger keyPathIndex = [paths indexOfObject:keyPath];
            if (keyPathIndex != NSNotFound) {
                
                NSRange subArrayRange;
                subArrayRange.location = (keyPathIndex + 1);
                if (subArrayRange.location < [paths count]) {
                    
                    subArrayRange.length = ([paths count] - subArrayRange.location);
                    NSArray *subArray = [paths subarrayWithRange:subArrayRange];
                    [subArray enumerateObjectsUsingBlock:^(NSString *longerKeyPath,
                                                           NSUInteger longerKeyPathIdx,
                                                           BOOL *longerKeyPathEnumeratorStop) {
                        
                        if ([keyPath isEqualToString:@"*"] || [longerKeyPath hasPrefix:keyPath]) {
                            
                            [paths removeObject:longerKeyPath];
                        }
                    }];
                }
            }
        }];
    }
    
    
    return ([keyPaths count] > 1 ? [paths copy] : keyPaths);
}


#pragma mark - Instance methods

- (BOOL)pn_isValidState {

    return [self count] && [self pn_isValidState:YES];
}

- (BOOL)pn_isValidState:(BOOL)isFirstLevelNesting {

    __block BOOL isValidState = YES;


    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *keysEnumeratorStop) {

        if ([value isKindOfClass:[NSDictionary class]]) {

            isValidState = NO;
            if (isFirstLevelNesting) {

                isValidState = [value pn_isValidState:NO];
            }
        }
        else {

            isValidState = ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] ||
                               [value isKindOfClass:[NSNull class]]);
        }

        *keysEnumeratorStop = !isValidState;
    }];


    return isValidState;
}

- (NSString *)logDescription {
    
    NSMutableString *logDescription = [NSMutableString stringWithString:@"<{"];
    __block NSUInteger entryIdx = 0;
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *entryKey, id entry, BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry performSelector:@selector(logDescription)];
            entry = (entry ? entry : @"");
        }
        [logDescription appendFormat:@"%@:%@%@", entryKey, entry, (entryIdx + 1 != [self count] ? @"|" : @"")];
        entryIdx++;
    }];
    [logDescription appendString:@"}>"];
    
    
    return logDescription;
}

#pragma mark -


@end
