//
//  PNDataSynchronizationEvent.m
//  PubNub
//
//  Created by Sergey Mamontov on 1/10/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "PNDataSynchronizationEvent+Protected.h"
#import "PNSynchronizationChannel+Protected.h"
#import "NSObject+PNPrivateAdditions.h"
#import "NSArray+PNAdditions.h"
#import "PNMacro.h"
#import "PNDate.h"


#pragma mark Types & Structures

struct PNDataSynchronizationEventDataKeysStruct PNDataSynchronizationEventDataKeys = {

    .action = @"action",
    .timeToken = @"timetoken",
    .location = @"updateAt",
    .value = @"value",
    .transactionStatus = @"status",
    .transactionIdentifier = @"trans_id",
};


#pragma mark Public interface implementation

@implementation PNDataSynchronizationEvent


#pragma mark - Class methods

+ (instancetype)eventAt:(NSString *)objectIdentifierWithPath
            withPayload:(NSDictionary *)eventPayload {

    NSString *objectIdentifier = [PNSynchronizationChannel objectIdentifierFrom:objectIdentifierWithPath];
    NSString *modificationLocation = [PNSynchronizationChannel objectModificationLocationFrom:objectIdentifierWithPath];
    NSString *timeToken = [eventPayload valueForKey:PNDataSynchronizationEventDataKeys.timeToken];
    NSString *transactionIdentifier = [eventPayload valueForKey:PNDataSynchronizationEventDataKeys.transactionIdentifier];
    NSString *transactionStatus = [eventPayload valueForKey:PNDataSynchronizationEventDataKeys.transactionStatus];
    NSString *action = [eventPayload valueForKey:PNDataSynchronizationEventDataKeys.action];
    NSString *relativeLocation = [eventPayload valueForKey:PNDataSynchronizationEventDataKeys.location];
    id data = [eventPayload valueForKey:PNDataSynchronizationEventDataKeys.value];

    PNDataSynchronizationEventType type = PNDataTransactionCompleteEvent;
    if (!transactionStatus) {

        if ([action isEqualToString:@"merge"] || [action isEqualToString:@"push"]) {

            type = PNDataUpdateEvent;
        }
        else if ([action isEqualToString:@"replace"]) {

            type = PNDataReplaceEvent;
        }
        else if ([action isEqualToString:@"replace-delete"] || [action isEqualToString:@"delete"]) {

            type = PNDataDeleteEvent;
        }
    }


    return [[self alloc] initEvent:type forRemoteObject:objectIdentifier
             transactionIdentifier:transactionIdentifier location:modificationLocation
                  relativeLocation:relativeLocation timeToken:timeToken andData:data];
}

+ (BOOL)isDataSynchronizationEvent:(NSDictionary *)eventPayload {

    BOOL isDataSynchronizationEvent = NO;
    if ([eventPayload isKindOfClass:[NSDictionary class]]) {

        BOOL isSynchronizationEvent = ([eventPayload objectForKey:PNDataSynchronizationEventDataKeys.action] != nil &&
                [eventPayload objectForKey:PNDataSynchronizationEventDataKeys.transactionIdentifier] != nil &&
                [eventPayload objectForKey:PNDataSynchronizationEventDataKeys.timeToken] != nil &&
                [eventPayload objectForKey:PNDataSynchronizationEventDataKeys.location] != nil);

        BOOL isTransactionNotificationEvent = ([eventPayload objectForKey:PNDataSynchronizationEventDataKeys.transactionStatus] != nil &&
                [eventPayload objectForKey:PNDataSynchronizationEventDataKeys.timeToken] != nil &&
                [eventPayload objectForKey:PNDataSynchronizationEventDataKeys.transactionIdentifier] != nil);

        isDataSynchronizationEvent = (isSynchronizationEvent || isTransactionNotificationEvent);
    }


    return isDataSynchronizationEvent;
}


#pragma mark - Instance methods

- (instancetype)initEvent:(PNDataSynchronizationEventType)type forRemoteObject:(NSString *)objectIdentifier
    transactionIdentifier:(NSString *)transactionIdentifier location:(NSString *)modificationLocation
         relativeLocation:(NSString *)relativeModificationLocation
                timeToken:(NSString *)modificationTimeToken andData:(id)data {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.type = type;
        self.objectIdentifier = objectIdentifier;
        self.modificationLocation = modificationLocation;
        self.relativeLocation = relativeModificationLocation;
        self.modificationTimeToken = modificationTimeToken;
        self.moidificationTransactionIdentifier = transactionIdentifier;


        if (data) {

            NSArray *dataLocationKeyPathComponents = [self.modificationLocation componentsSeparatedByString:@"."];

            // Check whether fetched data represent list or not
            if ([NSArray pn_isEntryIndexString:[dataLocationKeyPathComponents objectAtIndex:0]]) {

                self.data = [NSMutableArray array];
            }

            if (self.data == nil) {

                self.data = [NSMutableDictionary dictionary];
            }

            @autoreleasepool {

                [self.data pn_mergeRemoteObjectData:@{
                      [dataLocationKeyPathComponents lastObject]:@{
                              @"pn_tt" : self.modificationTimeToken, @"pn_val" : data
                              }
                      }];
            }
        }
    }


    return self;
}

- (NSString *)description {

    NSString *action = @"update";
    if (self.type == PNDataReplaceEvent) {

        action = @"replace";
    }
    else if (self.type == PNDataDeleteEvent) {

        action = @"delete";
    }
    else if (self.type == PNDataTransactionCompleteEvent) {

        action = @"complete";
    }

    NSString *kind = @"event";
    if (self.type == PNDataTransactionCompleteEvent) {

        kind = @"transaction";
    }

    NSNumber *timeToken = PNNumberFromUnsignedLongLongString(self.modificationTimeToken);
    PNDate *date = [PNDate dateWithToken:timeToken];


    return [NSString stringWithFormat:@"%@\nEVENT: %@ (%@)\nOBJECT: %@ (%@)\nDATE: %@\nRELATIVE LOCATION: %@\nTRANSACTION IDENTIFIER: %@\nDATA: %@",
                    NSStringFromClass([self class]), action, kind, self.objectIdentifier,
                    self.modificationLocation, date.date, self.relativeLocation,
                    self.moidificationTransactionIdentifier, self.data];
}

- (NSString *)logDescription {

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%d|%@|%@|%@|%@|%@|%@>", self.type, self.objectIdentifier,
                    self.modificationLocation, self.modificationTimeToken, self.relativeLocation, self.moidificationTransactionIdentifier,
                    (self.data ? [self.data performSelector:@selector(logDescription)] : [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
