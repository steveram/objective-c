//
//  PNUIBasicClientTestCase.h
//  PubNub
//
//  Created by Jordan Zucker on 8/27/15.
//  Copyright (c) 2015 Jordan Zucker. All rights reserved.
//

#import <PubNub/PubNub.h>
#import "JSZVCRKIFTestCase.h"

#define PNWeakify(__var) \
__weak __typeof__(__var) __var ## _weak_ = (__var)

#define PNStrongify(__var) \
_Pragma("clang diagnostic push"); \
_Pragma("clang diagnostic ignored  \"-Wshadow\""); \
__strong __typeof__(__var) __var = __var ## _weak_; \
_Pragma("clang diagnostic pop") \

typedef void (^PNChannelGroupAssertions)(PNAcknowledgmentStatus *status);

@class PubNub;

@interface PNUIBasicClientTestCase : JSZVCRKIFTestCase <PNObjectEventListener>

@property (nonatomic) PNConfiguration *configuration;
@property (nonatomic) PubNub *client;

- (void)performVerifiedAddChannels:(NSArray *)channels toGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

- (void)performVerifiedRemoveAllChannelsFromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

- (void)performVerifiedRemoveChannels:(NSArray *)channels fromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions;

@end
