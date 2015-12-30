/**
 @author Sergey Mamontov
 @version 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNSubscribeEventInformation+Protected.h"
#import "PNJSONSerialization.h"

#pragma mark Structures

struct PNEventDebugEnvelopeStructure PNDebugEventEnvelope = {
    .shardIdentifier = @"a",
    .debugFlags = @"f",
    .senderIdentifier = @"i",
    .sequenceNumber = @"s",
    .subscribeKey = @"k",
    .replicationMap = @"r",
    .eatAfterReading = @"ear",
    .meta = @"u",
    .waypoints = @"w"
};


#pragma mark - Interface implementation

@implementation PNSubscribeEventInformation


#pragma mark - Initialization and Configuration

+ (instancetype)subscribeEventInformationWithPayload:(NSDictionary *)payload {

    return [[self alloc] initWithPayload:payload];
}

- (instancetype)initWithPayload:(NSDictionary *)payload {

    // Check whether initialization was successful or not.
    if ((self = [super init])) {

        _shardIdentifier = [payload[PNDebugEventEnvelope.shardIdentifier] copy];
        _debugFlags = [payload[PNDebugEventEnvelope.debugFlags] copy];
        _senderIdentifier = [payload[PNDebugEventEnvelope.senderIdentifier] copy];
        _sequenceNumber = [payload[PNDebugEventEnvelope.sequenceNumber] copy];
        _subscribeKey = [payload[PNDebugEventEnvelope.subscribeKey] copy];
        _replicationMap = [payload[PNDebugEventEnvelope.replicationMap] copy];
        _eatAfterReading = payload[PNDebugEventEnvelope.eatAfterReading];
        _meta = [payload[PNDebugEventEnvelope.meta] copy];
        _waypoints = [payload[PNDebugEventEnvelope.waypoints] copy];
    }

    return self;
}

- (BOOL)shouldEatAfterReading {

    return self.eatAfterReading.boolValue;
}

#pragma mark - Misc

- (NSString *)description {

    return [[NSString alloc] initWithFormat:@"%@ (%p) <shard identifier: %@, flags: %@, client "
            "identifier: %@, sequence number: %@, subscribe key: %@, replication map: %@, "
            "eat after reading: %@, meta: %@, waypoints: %@>",
            NSStringFromClass([self class]), (__bridge void*)self,
            (self.shardIdentifier?: @"<null>"), (self.debugFlags?: @"<null>"),
            (self.senderIdentifier?: @"<null>"), (self.sequenceNumber?: @"<null>"),
            (self.subscribeKey?: @"<null>"), (self.replicationMap?: @"<null>"),
            (self.eatAfterReading ? (self.shouldEatAfterReading ? @"YES" : @"NO") : @"<null>"),
            (self.meta ? [PNJSONSerialization stringFromJSONObject:self.meta] : @"<null>"),
            (self.waypoints ? [PNJSONSerialization stringFromJSONObject:self.waypoints] : @"<null>")];
}

- (NSString *)logDescription {

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [[NSString alloc] initWithFormat:@"<%@|%@|%@|%@|%@|%@|%@|%@|%@>",
            (self.shardIdentifier?: [NSNull null]), (self.debugFlags?: [NSNull null]),
            (self.senderIdentifier?: [NSNull null]), (self.sequenceNumber?: [NSNull null]),
            (self.subscribeKey?: [NSNull null]), (self.replicationMap?: [NSNull null]),
            (self.eatAfterReading ? (self.shouldEatAfterReading ? @"YES" : @"NO") : [NSNull null]),
            ([self.meta performSelector:@selector(logDescription)]?: [NSNull null]),
            ([self.waypoints performSelector:@selector(logDescription)]?: [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
