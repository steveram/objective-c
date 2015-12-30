/**
 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */
#import "PNChannelEventsResponseParser+Protected.h"
#import "PNSubscribeEventInformation.h"
#import "PNChannelPresence+Protected.h"
#import "PNPresenceEvent+Protected.h"
#import "PNResponse+Protected.h"
#import "PNPrivateImports.h"
#import "PNChannelGroup.h"
#import "PNTimeToken.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub channel events response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

/**
 @brief  Stores reference on key under which request status is stored.
 */
static NSString * const kPNResponseStatusKey = @"s";

/**
 @brief  Stores reference on key under which service advisory information stored.
 */
static NSString * const kPNResponseAdvisoryKey = @"a";

/**
 @brief  Stores reference on key under which stored information about when event has been triggered
         by server and from which region.
 */
static NSString * const kPNResponseEventTimeKey = @"t";

/**
 @brief  Stores reference on key under which list of events is stored.
 */
static NSString * const kPNResponseEvenetsListKey = @"m";


#pragma mark - Structures

struct PNEventTimeTokenStructure PNEventTimeToken = {
    .timeToken = @"t",
    .region = @"r"
};

struct PNEventEnvelopeStructure PNEventEnvelope = {
    .senderTimeToken = { .key = @"o" },
    .publishTimeToken = { .key = @"p" },
    .actualChannel = @"c",
    .subscribedChannel = @"b",
    .payload = @"d",
    .presence = { .action = @"action", .data = @"data", .occupancy = @"occupancy",
                  .timestamp = @"timestamp", .uuid = @"uuid" }
};


#pragma mark - Public interface methods

@implementation PNChannelEventsResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)__unused response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);

    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {

    BOOL conforms = NO;

    // Checking base requirement about payload data type.
    if ([response.response isKindOfClass:NSDictionary.class]) {

        NSDictionary *responseData = response.response;
        conforms = (responseData[kPNResponseEventTimeKey] != nil &&
                    responseData[kPNResponseEvenetsListKey] != nil);
        conforms = (conforms && [responseData[kPNResponseEventTimeKey] isKindOfClass:NSDictionary.class]);
        conforms = (conforms && [responseData[kPNResponseEvenetsListKey] isKindOfClass:NSArray.class]);
        if (conforms) {

            NSDictionary *timeToken = responseData[kPNResponseEventTimeKey];
            conforms = (timeToken[PNEventTimeToken.timeToken] != nil &&
                        timeToken[PNEventTimeToken.region] != nil);
        }
    }

    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        NSDictionary *responseData = response.response;
        self.events = [PNChannelEvents new];

        // Time token information extraction block.
        PNTimeToken* (^timeTokenExtractBlock)(NSDictionary *) = ^(NSDictionary *information) {

            return [PNTimeToken timeTokenWithTime:information[PNEventTimeToken.timeToken]
                                        andRegion:information[PNEventTimeToken.region]];
        };
        
        // Retrieve event trigger time token
        self.events.timeToken = timeTokenExtractBlock(responseData[kPNResponseEventTimeKey]);

        // Retrieving list of events
        NSArray *events = responseData[kPNResponseEvenetsListKey];
        NSMutableArray *eventObjects = [[NSMutableArray alloc] initWithCapacity:[events count]];
        [events enumerateObjectsUsingBlock:^(NSDictionary *event, __unused NSUInteger eventIdx,
                                             __unused BOOL *eventsEnumeratorStop) {
            
            __block BOOL isPresenceObservationChannel = NO;
            PNChannel* (^channelExtractBlock)(NSString *) = ^(NSString *channelName) {
                
                PNChannel *channel = nil;
                if (channelName) {
                    
                    // Retrieve reference on channel on which event is occurred
                    channel = [PNChannel channelWithName:channelName];
                    
                    // Checking whether event occurred on presence observing channel or no and
                    // retrieve reference on original channel
                    isPresenceObservationChannel = ([channel isPresenceObserver]);
                    if (isPresenceObservationChannel) {
                        
                        channel = [(PNChannelPresence *)channel observedChannel];
                    }
                }
                
                return channel;
            };
            
            // Extracting channel names information.
            NSString *channelName = [event valueForKey:PNEventEnvelope.actualChannel];
            NSString *subscriptionMatch = [event valueForKey:PNEventEnvelope.subscribedChannel];
            if ([channelName isEqualToString:subscriptionMatch]) { subscriptionMatch = nil; }
            
            id eventObject = nil;
            id payload = [event valueForKey:PNEventEnvelope.payload];
            PNChannelGroup *group = nil;
            PNChannel *channel = channelExtractBlock(channelName);
            PNChannel *detailedChannel = channelExtractBlock(subscriptionMatch);
            if (detailedChannel && detailedChannel.isChannelGroup) {
                
                group = (PNChannelGroup *)detailedChannel;
            }
            
            // Checking whether event presence event or not
            if (isPresenceObservationChannel) {
                
                eventObject = [PNPresenceEvent presenceEventForResponse:payload onChannel:channel
                                                           channelGroup:group];
            }
            else {

                PNTimeToken *eventTimeToken = timeTokenExtractBlock(event[PNEventEnvelope.senderTimeToken.key]?:
                                                                    event[PNEventEnvelope.publishTimeToken.key]);
                eventObject = [PNMessage messageFromServiceResponse:payload onChannel:channel
                                                       channelGroup:group atDate:eventTimeToken];
            }

            [eventObject performSelector:@selector(setDebugInformation:)
              withObject:[PNSubscribeEventInformation subscribeEventInformationWithPayload:event]];
            [eventObjects addObject:eventObject];
        }];
        
        self.events.events = eventObjects;
    }

    return self;
}

- (id)parsedData {

    return self.events;
}

- (NSString *)description {

    return [[NSString alloc] initWithFormat:@"%@ (%p) <time token: <%@>, events: %@>",
            NSStringFromClass([self class]), (__bridge void *)self, self.events.timeToken,
            self.events.events];
}

- (NSString *)logDescription {
    
    return [[NSString alloc] initWithFormat:@"<%@|%@>",
            ([self.events.timeToken performSelector:@selector(logDescription)]?: [NSNull null]),
            ([self.events.events performSelector:@selector(logDescription)]?: [NSNull null])];
}

#pragma mark -


@end
