//
//  NSObject+PNPrivateAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 9/6/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSObject+PNPrivateAdditions.h"
#import "NSObject+PNAdditions.h"
#import "NSArray+PNAdditions.h"
#import <objc/runtime.h>
#import "PNHelper.h"
#import "PNMacro.h"
#import "PNDate.h"


#define DEBUG_QUEUE 0
#if DEBUG_QUEUE
    #warning Queue assertion is ON. Turn OFF before deployment.
#endif


#pragma mark Category private interface declaration

@interface NSObject (PNAdditionsProtected)


#pragma mark - Instance methods

#pragma mark - Misc methods

/**
 @brief Look into instance storage for information about whether object discard requirement on code
 execution only on private queue or not.
 
 @return \c YES will allow to execute submitted block w/o check and treated as private by default.
 
 @since 3.7.3
 */
- (BOOL)pn_ignoringPrivateQueueRequirement;

/**
 @brief Allow to check whether currently instance code is running on it's private queue or not.
 
 @return \c YES in case if dispatch_get_specific for pointer stored inside of associated object will
 return non-NULL information.
 
 @since 3.7.3
 */
- (BOOL)pn_runningOnPrivateQueue;

/**
 @brief Try to retrieve reference on wrapper which should be stored as associated object of instance
 if queue has been configured before.
 
 @return \c nil in case if private queue never been configured for this instance.
 
 @since 3.7.3
 */
- (PNDispatchObjectWrapper *)pn_privateQueueWrapper;

#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation NSObject (PNPrivateAdditions)


#pragma mark - Instance methods

#pragma mark - Data synchronization methods

- (void)pn_setModificationDate:(NSNumber *)modificationTimeToken {
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        
        [(NSDictionary *)self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            [obj pn_setModificationDate:modificationTimeToken];
        }];
    }
    else if ([self isKindOfClass:[NSArray class]]){
        
        [(NSArray *)self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            [obj pn_setModificationDate:modificationTimeToken];
        }];
    }
    else {
        
        objc_setAssociatedObject(self, "pn_modificationDate", modificationTimeToken, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)pn_setIndex:(NSString *)index {
    
    objc_setAssociatedObject(self, "pn_index", index, OBJC_ASSOCIATION_RETAIN);
}

- (void)pn_mergeData:(id)data at:(NSString *)dataLocationKeyPath {

    if ([dataLocationKeyPath length]) {

        __block id storedObject = self;

        // Checking whether data which should be stored represent PNValue or collection.
        BOOL isValue = ![data respondsToSelector:@selector(count)];

        __block id previousStoredObject = storedObject;
        NSArray *keyPathComponents = [dataLocationKeyPath componentsSeparatedByString:@"."];
        [keyPathComponents enumerateObjectsUsingBlock:^(NSString *pathComponent,
                                                        NSUInteger pathComponentIdx,
                                                        BOOL *pathComponentEnumeratorStop) {

            BOOL isLastPathComponents = (pathComponentIdx + 1 == [keyPathComponents count]);
            BOOL isPathRepresentList = [NSArray pn_isEntryIndexString:pathComponent];
            if (isPathRepresentList) {

                storedObject = [(NSMutableArray *)storedObject pn_objectAtIndex:pathComponent];
            }
            else {

                storedObject = [(NSMutableDictionary *)storedObject valueForKey:pathComponent];
            }

            if (!storedObject) {

                BOOL representListObject = [data isKindOfClass:[NSArray class]];
                if (!isLastPathComponents) {

                    NSString *nextPathComponent = [keyPathComponents objectAtIndex:(pathComponentIdx + 1)];
                    representListObject = [NSArray pn_isEntryIndexString:nextPathComponent];
                }

                if (representListObject) {

                    storedObject = [NSMutableArray array];
                }
                else {

                    storedObject = [NSMutableDictionary dictionary];
                }

                if (isPathRepresentList) {

                    [storedObject pn_setIndex:pathComponent];
                    [(NSMutableArray *)previousStoredObject addObject:storedObject];
                    [(NSMutableArray *)previousStoredObject sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

                        return [[obj1 pn_index] compare:[obj2 pn_index]];
                    }];
                }
                else {

                    [(NSMutableDictionary *)previousStoredObject setValue:storedObject
                                                                   forKey:pathComponent];
                }
            }
            else {

                if (isLastPathComponents) {

                    // Check whether stored data represent non-collection instance or not
                    if (![storedObject respondsToSelector:@selector(count)]) {

                        id dataForReplacement = nil;

                        // This shouldn't happen usually, but possible that simple value has been
                        // replaced with collection.
                        if (!isValue) {

                            if ([data isKindOfClass:[NSArray class]]) {

                                dataForReplacement = [NSMutableArray array];
                            }
                            else {

                                dataForReplacement = [NSMutableDictionary dictionary];
                            }
                        }

                        if (dataForReplacement) {

                            if ([previousStoredObject isKindOfClass:[NSMutableArray class]]) {

                                [dataForReplacement pn_setIndex:[storedObject pn_index]];
                                [(NSMutableArray *)previousStoredObject removeObject:storedObject];
                                [(NSMutableArray *)previousStoredObject addObject:dataForReplacement];
                                [(NSMutableArray *)previousStoredObject sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

                                    return [[obj1 pn_index] compare:[obj2 pn_index]];
                                }];
                            }
                            else {

                                [(NSMutableDictionary *)previousStoredObject setValue:storedObject
                                                                               forKey:pathComponent];
                            }

                            storedObject = dataForReplacement;
                        }
                    }
                }
            }

            previousStoredObject = storedObject;
        }];

        [storedObject pn_mergeData:data];
    }
    else {

        if (![(NSMutableArray *)self count]) {

            if ([self isKindOfClass:[NSMutableArray class]]) {

                if ([data isKindOfClass:[NSArray class]]) {

                    [(NSMutableArray *)self addObjectsFromArray:(NSArray *)data];
                }
                else {

                    [(NSMutableArray *)self addObject:data];
                }
            }
            else if ([data isKindOfClass:[NSDictionary class]]) {

                [(NSMutableDictionary *)self addEntriesFromDictionary:data];
            }
        }
        else {

            [self pn_mergeData:data];
        }
    }
}

- (void)pn_mergeData:(id)data {

    if ([self isKindOfClass:[NSMutableArray class]]) {

        // In case if suggested object represent some collection, it doesn't have any
        // modification dates to check whether provided data should be accept  ed or not
        if ([data respondsToSelector:@selector(count)]) {

            if ([data isKindOfClass:[NSMutableArray class]]) {

                [(NSArray *)[data copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                    id oldObject = [(NSMutableArray *)self pn_objectAtIndex:[obj pn_index]];
                    if (oldObject) {

                        if ([oldObject respondsToSelector:@selector(count)]) {

                            if ([oldObject isKindOfClass:[NSArray class]] ||
                                [obj isKindOfClass:[NSDictionary class]]) {

                                [oldObject pn_mergeData:obj];
                            }
                            else {

                                [(NSMutableArray *)self removeObject:oldObject];
                                [(NSMutableArray *)self addObject:obj];
                            }
                        }
                        else {

                            BOOL shouldAcceptUpdate = NO;
                            if (![obj respondsToSelector:@selector(count)]) {

                                unsigned long long dataModificationDate = [[data pn_modificationDate] unsignedLongLongValue];
                                unsigned long long storedEntryModificationDate = [[oldObject pn_modificationDate] unsignedLongLongValue];
                                shouldAcceptUpdate = (storedEntryModificationDate != 0 && dataModificationDate > storedEntryModificationDate);
                            }

                            if (shouldAcceptUpdate || [obj respondsToSelector:@selector(count)]) {

                                [(NSMutableArray *)self removeObject:oldObject];
                                [(NSMutableArray *)self addObject:obj];
                            }
                        }
                    }
                    else {

                        [(NSMutableArray *)self addObject:obj];
                    }
                }];
            }
            else {

                id oldObject = [(NSMutableArray *)self pn_objectAtIndex:[data pn_index]];
                if (oldObject) {

                    if ([oldObject respondsToSelector:@selector(count)]) {

                        [oldObject pn_mergeData:data];
                    }
                    else {

                        [(NSMutableArray *)self removeObject:oldObject];
                        [(NSMutableArray *)self addObject:data];
                    }
                }
                else {

                    [(NSMutableArray *)self addObject:data];
                }
            }
        }
        else {

            NSMutableArray *target = (NSMutableArray *)self;
            id oldObject = [(NSMutableArray *)self pn_objectAtIndex:[data pn_index]];
            BOOL shouldAcceptUpdate = (oldObject == nil);
            if (oldObject) {

                if ([oldObject respondsToSelector:@selector(count)]) {

                    if ([oldObject isKindOfClass:[NSMutableArray class]]) {

                        target = oldObject;
                    }
                    else {

                        [(NSMutableArray *)self removeObject:oldObject];
                    }
                }
                else {

                    unsigned long long dataModificationDate = [[data pn_modificationDate] unsignedLongLongValue];
                    unsigned long long storedEntryModificationDate = [[oldObject pn_modificationDate] unsignedLongLongValue];
                    shouldAcceptUpdate = (storedEntryModificationDate != 0 && dataModificationDate > storedEntryModificationDate);
                    if (shouldAcceptUpdate) {

                        [target removeObject:oldObject];
                    }
                }
            }

            if (shouldAcceptUpdate) {

                [target addObject:data];
                if (![target isEqual:self]) {

                    [target sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

                        return [[obj1 pn_index] compare:[obj2 pn_index]];
                    }];
                }
            }
        }
    }
    else {

        if ([data isKindOfClass:[NSDictionary class]]) {

            [(NSDictionary *)[data copy] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

                id dictObject = [(NSDictionary *)self valueForKey:key];
                BOOL shouldAcceptUpdate = (dictObject == nil);
                if (dictObject) {

                    if ([dictObject respondsToSelector:@selector(count)]) {

                        if ([dictObject isKindOfClass:[NSArray class]] ||
                            [obj isKindOfClass:[NSDictionary class]]) {

                            shouldAcceptUpdate = NO;
                            [dictObject pn_mergeData:obj];
                        }
                    }
                    else {

                        unsigned long long dataModificationDate = [[obj pn_modificationDate] unsignedLongLongValue];
                        unsigned long long storedEntryModificationDate = [[dictObject pn_modificationDate] unsignedLongLongValue];
                        shouldAcceptUpdate = (storedEntryModificationDate != 0 && dataModificationDate > storedEntryModificationDate);
                    }
                }

                if (shouldAcceptUpdate) {

                    [(NSMutableDictionary *)self setValue:obj forKey:key];
                }
            }];
        }
    }


    if ([self isKindOfClass:[NSMutableArray class]]) {

        [(NSMutableArray *)self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

            return [[obj1 pn_index] compare:[obj2 pn_index]];
        }];
    }

}

- (void)pn_mergeRemoteObjectData:(NSDictionary *)pubNubCloudData {

    [pubNubCloudData enumerateKeysAndObjectsUsingBlock:^(NSString *objectKey, NSDictionary *object,
                                                         BOOL *objectEnumeratorStop) {

        // Checking whether object represent PNValue or another collection
        BOOL isValue = ([object objectForKey:@"pn_tt"] != nil);

        // Check whether dictionary contains entries from \b PubNub cloud remote object's
        // list.
        BOOL isList = [NSArray pn_isEntryIndexString:[[object allKeys] objectAtIndex:0]];

        id storedData = nil;
        if ([self isKindOfClass:[NSMutableArray class]]) {

            // Fetching object from list which maybe has been pulled out earlier
            storedData = [(NSMutableArray *)self pn_objectAtIndex:objectKey];
        }
        else {

            // Fetching object from list which maybe has been pulled out earlier
            storedData = [(NSMutableDictionary *)self valueForKey:objectKey];
        }

        if (!storedData) {

            if (isValue) {

                NSNumber *modificationTimeToken = PNNumberFromUnsignedLongLongString([object valueForKey:@"pn_tt"]);
                storedData = [object valueForKey:@"pn_val"];
                [storedData pn_setModificationDate:modificationTimeToken];
            }
            else {

                if (isList) {

                    storedData = [NSMutableArray array];
                }
                else {

                    storedData = [NSMutableDictionary dictionary];
                }
                
                if ([NSArray pn_isEntryIndexString:objectKey]) {
                    
                    [storedData pn_setIndex:objectKey];
                }

                // Use received object to merge it with data entry at the root
                [storedData pn_mergeRemoteObjectData:object];
            }

            if ([self isKindOfClass:[NSMutableArray class]]) {

                [(NSMutableArray *)self addObject:storedData];
            }
            else {

                [(NSMutableDictionary *)self setValue:storedData forKey:objectKey];
            }
        }
        else {

            // Check whether stored data represent non-collection instance or not
            if (![storedData respondsToSelector:@selector(count)]) {

                id dataForReplacement = nil;

                // This shouldn't happen usually, but possible that simple value has been
                // replaced with collection.
                if (!isValue) {

                    if (isList) {

                        dataForReplacement = [NSMutableArray array];
                    }
                    else {

                        dataForReplacement = [NSMutableDictionary dictionary];
                    }

                    // Use received object to merge it with data entry at the root
                    [dataForReplacement pn_mergeRemoteObjectData:object];
                }
                else {

                    dataForReplacement = [object valueForKey:@"pn_val"];
                    [dataForReplacement pn_setModificationDate:PNNumberFromUnsignedLongLongString([object valueForKey:@"pn_tt"])];
                }

                if (dataForReplacement) {

                    if ([self isKindOfClass:[NSMutableArray class]]) {

                        [dataForReplacement pn_setIndex:[storedData pn_index]];
                        [(NSMutableArray *)self removeObject:storedData];
                        [(NSMutableArray *)self addObject:dataForReplacement];
                    }
                    else {

                        [(NSMutableDictionary *)self setValue:dataForReplacement
                                                       forKey:objectKey];
                    }
                }
            }
            else {

                // Use received object to merge it with data entry at the root
                [storedData pn_mergeRemoteObjectData:object];
            }
        }
    }];
    
    if ([self isKindOfClass:[NSMutableArray class]]) {

        [(NSMutableArray *)self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

            return [[obj1 pn_index] compare:[obj2 pn_index]];
        }];
    }
}

- (void)pn_removeRemoteObjectDataAtPath:(NSString *)dataLocationKeyPath {
    
    if ([dataLocationKeyPath length]) {
        
        NSArray *keyPathComponents = [dataLocationKeyPath componentsSeparatedByString:@"."];
        id entry = nil;
        
        if ([self isKindOfClass:[NSMutableArray class]]) {
            
            // Ensure that first element in requested path is entry index
            if ([NSArray pn_isEntryIndexString:[keyPathComponents objectAtIndex:0]]) {
                
                entry = [(NSMutableArray *)self pn_objectAtIndex:[keyPathComponents objectAtIndex:0]];
            }
        }
        else {
            
            entry = [(NSMutableDictionary *)self valueForKey:[keyPathComponents objectAtIndex:0]];
        }
        
        if (entry) {
            
            // Check whether stored data represent non-collection instance or not
            if (![entry respondsToSelector:@selector(count)] || [keyPathComponents count] == 1) {
                
                if ([self isKindOfClass:[NSMutableArray class]]) {
                    
                    [(NSMutableArray *)self removeObject:entry];
                }
                else {
                    
                    [(NSMutableDictionary *)self removeObjectForKey:[keyPathComponents objectAtIndex:0]];
                }
            }
            else {
                
                NSUInteger keyPathIndex = 0;
                NSRange subArrayRange;
                subArrayRange.location = (keyPathIndex + 1);
                if (subArrayRange.location < [keyPathComponents count]) {
                    
                    subArrayRange.length = ([keyPathComponents count] - subArrayRange.location);
                    NSArray *subArray = [keyPathComponents subarrayWithRange:subArrayRange];
                    
                    if ([subArray count]) {
                        
                        [entry pn_removeRemoteObjectDataAtPath:[subArray componentsJoinedByString:@"."]];
                        if (![(NSMutableArray *)entry count]) {

                            if ([self isKindOfClass:[NSMutableArray class]]) {

                                [(NSMutableArray *)self removeObject:entry];
                            }
                            else {

                                [(NSMutableDictionary *)self removeObjectForKey:[keyPathComponents objectAtIndex:0]];
                            }
                        }
                    }
                }
            }
        }
    }
    // Looks like all data should be removed.
    else {
        
        if ([self isKindOfClass:[NSMutableArray class]]) {
            
            [(NSMutableArray *)self removeAllObjects];
        }
        else {
            
            [(NSMutableDictionary *)self removeAllObjects];
        }
    }
}


#pragma mark - GCD helper methods

- (dispatch_queue_t)pn_privateQueue {
    
    dispatch_queue_t queue = [self pn_privateQueueWrapper].queue;
    
    return (queue ? queue : NULL);
}

- (PNDispatchObjectWrapper *)pn_privateQueueWrapper {
    
    return (PNDispatchObjectWrapper *)objc_getAssociatedObject(self, "privateQueue");
}

- (void)pn_setupPrivateSerialQueueWithIdentifier:(NSString *)identifier
                                     andPriority:(dispatch_queue_priority_t)priority {
    
    dispatch_queue_t privateQueue = [PNDispatchHelper serialQueueWithIdentifier:identifier];
    dispatch_queue_t targetQueue = dispatch_get_global_queue(priority, 0);
    dispatch_set_target_queue(privateQueue, targetQueue);
    const char *cQueueIdentifier = dispatch_queue_get_label(privateQueue);
    
    // Construct pointer which will be used for code block execution and make sure to run code on provided queue.
    void *context = (__bridge void *)self;
    const void *privateQueueSpecificPointer = &cQueueIdentifier;
    dispatch_queue_set_specific(privateQueue, privateQueueSpecificPointer, context, NULL);
    
    // Store queue inside of wrapper as associated object of this instance
    PNDispatchObjectWrapper *wrapper = [PNDispatchObjectWrapper wrapperForObject:privateQueue
                                        specificKey:[NSValue valueWithPointer:privateQueueSpecificPointer]];
    if (wrapper) {
        
        objc_setAssociatedObject(self, "privateQueue", wrapper, OBJC_ASSOCIATION_RETAIN);
    }
    
}

- (void)pn_destroyPrivateDispatchQueue {
    
    [PNDispatchHelper release:[self pn_privateQueue]];
    objc_setAssociatedObject(self, "privateQueue", nil, OBJC_ASSOCIATION_RETAIN);
}

- (void)pn_dispatchBlock:(dispatch_block_t)block {

    dispatch_queue_t privateQueue = [self pn_privateQueue];
    NSAssert(privateQueue != NULL, @"The given block can't be scheduled because private queue not set yet.");

    [self pn_dispatchOnQueue:privateQueue block:block];
}

- (void)pn_dispatchOnQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {

    if (block) {

        if (queue) {

            // Check whether code is running on instance private queue or not
            if ([self pn_runningOnPrivateQueue]) {

                block();
            }
            else {

                dispatch_async(queue, block);
            }
        }
        else {

            block();
        }
    }
}

- (void)pn_scheduleOnPrivateQueueAssert {
    
#if DEBUG_QUEUE
    NSAssert([self pn_runningOnPrivateQueue], @"Code should be scheduled on private queue");
#endif
}

- (void)pn_ignorePrivateQueueRequirement {
    
    objc_setAssociatedObject(self, "ignorePrivateQueueRequirement", @YES, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Misc methods

- (BOOL)pn_ignoringPrivateQueueRequirement {
    
    return [(NSNumber *)objc_getAssociatedObject(self, "ignorePrivateQueueRequirement") boolValue];
}

- (BOOL)pn_runningOnPrivateQueue {
    
    BOOL runningOnPrivateQueue = [self pn_ignoringPrivateQueueRequirement];
    if (!runningOnPrivateQueue) {
        
        PNDispatchObjectWrapper *wrapper = [self pn_privateQueueWrapper];
        if (wrapper) {
            
            runningOnPrivateQueue = [(__bridge id)dispatch_get_specific(wrapper.specificKeyPointer.pointerValue) isEqual:self];
        }
    }
    
    return runningOnPrivateQueue;
}

#pragma mark -


@end
