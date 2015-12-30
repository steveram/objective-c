//
//  PNPresenceEvent.m
//  pubnub
//
//  Object which is used to describe concrete
//  presence event which arrived from PubNub
//  services.
//
//
//  Created by Sergey Mamontov.
//
//
#import "PNPresenceEvent+Protected.h"
#import "PNSubscribeEventInformation.h"
#import "PNChannel+Protected.h"
#import "PNClient+Protected.h"
#import "PNChannelGroup.h"
#import "PNClient.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub presence event must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Structures

struct PNPresenceEventDataKeysStruct PNPresenceEventDataKeys = {
    .action = @"action",
    .timestamp = @"timestamp",
    .uuid = @"uuid",
    .data = @"data",
    .channel = @"channel",
    .occupancy = @"occupancy"
};


#pragma mark - Public interface methods

@implementation PNPresenceEvent


#pragma mark Class methods

+ (id)presenceEventForResponse:(id)presenceResponse onChannel:(PNChannel *)channel
                  channelGroup:(PNChannelGroup *)channelGroup {
    
    return [[self alloc] initWithResponse:presenceResponse onChannel:channel channelGroup:channelGroup];
}

+ (BOOL)isPresenceEventObject:(NSDictionary *)event {

    BOOL isPresenceEventObject = (event[PNPresenceEventDataKeys.timestamp] != nil &&
                                  event[PNPresenceEventDataKeys.occupancy] != nil);
    if (!isPresenceEventObject) {

        isPresenceEventObject = (event[PNPresenceEventDataKeys.action] != nil &&
                                 event[PNPresenceEventDataKeys.uuid] != nil);
    }

    return isPresenceEventObject;
}


#pragma mark - Instance methods

- (id)initWithResponse:(id)presenceResponse onChannel:(PNChannel *)channel
          channelGroup:(PNChannelGroup *)channelGroup {
    
    // Check whether initialization successful or not
    if((self = [super init])) {

        // Extracting event type from response
        self.type = PNPresenceEventJoin;
        NSString *type = (presenceResponse[PNPresenceEventDataKeys.action]?: @"interval");
        if ([type isEqualToString:@"leave"]) {

            self.type = PNPresenceEventLeave;
        }
        else if ([type isEqualToString:@"timeout"]) {

            self.type = PNPresenceEventTimeout;
        }
        else if ([type isEqualToString:@"state-change"]){

            self.type = PNPresenceEventStateChanged;
        }
        else if ([type isEqualToString:@"interval"]){

            self.type = PNPresenceEventChanged;
        }

        // Extracting event date from response
        NSNumber *timestamp = presenceResponse[PNPresenceEventDataKeys.timestamp];
        self.date = [PNDate dateWithToken:timestamp];

        // Extracting channel occupancy from response
        self.occupancy = [presenceResponse[PNPresenceEventDataKeys.occupancy] unsignedIntegerValue];
        
        // Extracting client specific state
        self.client = [PNClient clientForIdentifier:presenceResponse[PNPresenceEventDataKeys.uuid]
                                            channel:nil
                                            andData:presenceResponse[PNPresenceEventDataKeys.data]];

        self.channel = channel;
        self.channelGroup = channelGroup;
    }
    
    return self;
}


#pragma mark - Misc methods

- (void)setChannel:(PNChannel *)channel {

    _channel = channel;
    self.client.channel = channel;
}

- (void)setChannelGroup:(PNChannelGroup *)channelGroup {

    _channelGroup = channelGroup;
    self.client.group = channelGroup;
}

- (NSString *)description {

    NSString *action = @"join";
    if (self.type == PNPresenceEventLeave) {

        action = @"leave";
    }
    else if (self.type == PNPresenceEventTimeout) {

        action = @"timeout";
    }
    else if (self.type == PNPresenceEventStateChanged) {

        action = @"state changed";
    }
    else if (self.type == PNPresenceEventChanged) {

        action = @"occupancy changed";
    }

    return [[NSString alloc] initWithFormat:@"%@\nEVENT: %@\nCLIENT: %@\nDATE: %@\nOCCUPANCY: "
            "%ld\nCHANNEL: %@\nDEBUG: %@",
            NSStringFromClass([self class]), action, self.client, self.date,
            (unsigned long)self.occupancy, self.channel, self.debugInformation];
}

- (NSString *)logDescription {
    
    NSString *action = @"join";
    if (self.type == PNPresenceEventLeave) {
        
        action = @"leave";
    }
    else if (self.type == PNPresenceEventTimeout) {
        
        action = @"timeout";
    }
    else if (self.type == PNPresenceEventStateChanged) {
        
        action = @"state changed";
    }
    else if (self.type == PNPresenceEventChanged) {
        
        action = @"occupancy changed";
    }

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [[NSString alloc] initWithFormat:@"<%@|%@|%@|%ld|%@|%@>", action,
            ([self.date performSelector:@selector(logDescription)]?: [NSNull null]),
            ([self.channel performSelector:@selector(logDescription)]?: [NSNull null]),
            (unsigned long)self.occupancy,
            ([self.client performSelector:@selector(logDescription)]?: [NSNull null]),
            ([self.debugInformation performSelector:@selector(logDescription)]?: [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
