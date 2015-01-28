//
//  NSObject+PNAdditions.m
//  PubNub
//
//  Created by Sergey Mamontov on 1/16/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "NSObject+PNAdditions.h"
#import "NSArray+PNPrivateAdditions.h"
#import "NSArray+PNAdditions.h"
#import <objc/runtime.h>


#pragma mark Category implementation

@implementation NSObject (PNAdditions)


#pragma mark - Instance methods

- (NSNumber *)pn_modificationDate {
    
    return objc_getAssociatedObject(self, "pn_modificationDate");
}

- (NSString *)pn_index {
    
    return objc_getAssociatedObject(self, "pn_index");
}

- (id)pn_objectAtKeyPath:(NSString *)keyPath {
    
    id object = nil;
    NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
    if ([keyPathComponents count]) {
        
        __block id storedData = self;
        [keyPathComponents enumerateObjectsUsingBlock:^(NSString *pathComponent,
                                                        NSUInteger pathComponentIdx,
                                                        BOOL *pathComponentEnumeratorStop) {
            
            if ([NSArray pn_isEntryIndexString:pathComponent]) {
                
                if ([storedData isKindOfClass:[NSMutableArray class]]) {
                    
                    storedData = [(NSMutableArray *)storedData pn_objectAtIndex:pathComponent];
                }
                else {
                    
                    storedData = nil;
                }
            }
            else {
                
                if ([storedData isKindOfClass:[NSMutableDictionary class]]) {
                    
                    storedData = [(NSMutableDictionary *)storedData valueForKey:pathComponent];
                }
                else {
                    
                    storedData = nil;
                }
            }
        }];
        
        object = storedData;
    }
    
    
    return object;
}

#pragma mark -


@end
